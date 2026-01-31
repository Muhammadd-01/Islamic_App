import pkg from 'whatsapp-web.js';
const { Client, LocalAuth } = pkg;
import qrcode from 'qrcode';
import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';

const db = admin.firestore();

class WhatsAppService {
    constructor() {
        this.client = null;
        this.qrCode = null;
        this.status = 'DISCONNECTED'; // DISCONNECTED, INITIALIZING, QR_READY, CONNECTED
        this.adminNumber = null;
    }

    async initialize() {
        if (this.client) return;

        const sessionPath = path.resolve('.wwebjs_auth');
        const sessionExists = fs.existsSync(path.join(sessionPath, 'session-system-messenger'));

        console.log(`Initializing WhatsApp Client (Optimized)... Session exists: ${sessionExists}`);
        this.status = sessionExists ? 'RESUMING' : 'INITIALIZING';

        this.client = new Client({
            authStrategy: new LocalAuth({
                clientId: "system-messenger",
                dataPath: sessionPath
            }),
            authTimeoutMs: 90000,
            webVersion: '2.3000.1018911977', // Use a stable web version
            webVersionCache: {
                type: 'remote',
                remotePath: 'https://raw.githubusercontent.com/wppconnect-team/wa-js/main/dist/wppconnect-wa.js'
            },
            puppeteer: {
                handleSIGINT: false,
                executablePath: process.env.CHROME_PATH || undefined,
                args: [
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-accelerated-2d-canvas',
                    '--no-first-run',
                    '--no-zygote',
                    '--disable-gpu',
                    '--disable-extensions',
                    '--js-flags="--max-old-space-size=2048"'
                ]
            }
        });

        this.client.on('qr', (qr) => {
            console.log('QR Received - Scan this in Admin Profile');
            this.qrCode = qr;
            this.status = 'QR_READY';
        });

        this.client.on('ready', () => {
            console.log(`--- WHATSAPP READY [${this.client.info.wid.user}] ---`);
            this.status = 'CONNECTED';
            this.qrCode = null;
        });

        this.client.on('authenticated', () => {
            console.log('WhatsApp Authenticated. Syncing session...');
            this.status = 'AUTHENTICATED';

            // Periodically check if client.info becomes available before 'ready' fires
            const readyChecker = setInterval(() => {
                if (this.client?.info?.wid) {
                    console.log('Client Info found! Forcing READY state.');
                    this.status = 'CONNECTED';
                    this.qrCode = null;
                    clearInterval(readyChecker);
                }
            }, 2000);

            // Safety timeout for the checker
            setTimeout(() => clearInterval(readyChecker), 60000);
        });

        this.client.on('loading_screen', (percent, message) => {
            console.log(`WhatsApp loading: ${percent}% - ${message}`);
            this.syncProgress = { percent, message };
            if (percent === 100) {
                this.status = 'CONNECTED';
            } else if (this.status !== 'CONNECTED') {
                this.status = 'SYNCING';
            }
        });

        this.client.on('auth_failure', (msg) => {
            console.error('AUTHENTICATION FAILURE', msg);
            this.status = 'DISCONNECTED';
            this.qrCode = null;
        });

        this.client.on('disconnected', (reason) => {
            console.log('Client was logged out', reason);
            this.status = 'DISCONNECTED';
            this.qrCode = null;
        });

        try {
            await this.client.initialize();
        } catch (err) {
            console.error('Failed to initialize WA client:', err);
            this.status = 'DISCONNECTED';
        }
    }

    async getStatus() {
        let qrDataUrl = null;
        if (this.qrCode) {
            qrDataUrl = await qrcode.toDataURL(this.qrCode);
        }
        return {
            status: this.status,
            qrCode: qrDataUrl,
            syncProgress: this.syncProgress
        };
    }

    async sendMessage(to, message) {
        if (this.status !== 'CONNECTED') {
            console.warn('Cannot send message: WhatsApp not connected');
            return false;
        }

        try {
            // Ensure number is in correct format (remove plus, add @c.us)
            const cleanNumber = to.replace(/\+/g, '').replace(/\D/g, '');
            const chatId = `${cleanNumber}@c.us`;
            // sendSeen: false prevents the 'markedUnread' TypeError in many cases
            await this.client.sendMessage(chatId, message, { sendSeen: false });
            console.log(`Message sent to ${to}`);
            return true;
        } catch (error) {
            console.error('Error sending WhatsApp message:', error);
            return false;
        }
    }

    async logout() {
        console.log('[SYSTEM] Aggressive Logout: Destroying all WhatsApp sessions...');
        if (this.client) {
            try {
                await this.client.destroy(); // More thorough than logout()
            } catch (e) {
                console.warn('Error during client destroy:', e.message);
            }
            this.client = null;
        }

        this.status = 'DISCONNECTED';
        this.qrCode = null;

        // Physical deletion of session folders
        const folders = ['.wwebjs_auth', '.wwebjs_cache'];
        folders.forEach(folder => {
            const folderPath = path.resolve(folder);
            if (fs.existsSync(folderPath)) {
                try {
                    fs.rmSync(folderPath, { recursive: true, force: true });
                    console.log(`[SYSTEM] Deleted folder: ${folder}`);
                } catch (err) {
                    console.error(`[SYSTEM] Failed to delete ${folder}:`, err.message);
                }
            }
        });

        console.log('[SYSTEM] Sessions destroyed. Restarting client in 2s for fresh login...');
        setTimeout(() => {
            this.initialize();
        }, 2000);
    }
}

const whatsappService = new WhatsAppService();
export default whatsappService;

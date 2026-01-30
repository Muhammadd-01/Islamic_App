import pkg from 'whatsapp-web.js';
const { Client, LocalAuth } = pkg;
import qrcode from 'qrcode';
import admin from 'firebase-admin';

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

        console.log('Initializing WhatsApp Client...');
        this.status = 'INITIALIZING';

        this.client = new Client({
            authStrategy: new LocalAuth({ clientId: "system-messenger" }),
            puppeteer: {
                handleSIGINT: false,
                args: ['--no-sandbox', '--disable-setuid-sandbox']
            }
        });

        this.client.on('qr', (qr) => {
            console.log('QR Received - Scan this in Admin Profile');
            this.qrCode = qr;
            this.status = 'QR_READY';
        });

        this.client.on('ready', () => {
            console.log('--- WHATSAPP READY ---');
            this.status = 'CONNECTED';
            this.qrCode = null;
        });

        this.client.on('authenticated', () => {
            console.log('WhatsApp Authenticated. Finalizing setup...');
            this.status = 'AUTHENTICATED';
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
            // No auto-initialize here to prevent loops, user can reset via Admin Panel
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
            qrCode: qrDataUrl
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
            await this.client.sendMessage(chatId, message);
            console.log(`Message sent to ${to}`);
            return true;
        } catch (error) {
            console.error('Error sending WhatsApp message:', error);
            return false;
        }
    }

    async logout() {
        if (this.client) {
            await this.client.logout();
            this.client = null;
            this.status = 'DISCONNECTED';
            this.initialize();
        }
    }
}

const whatsappService = new WhatsAppService();
export default whatsappService;

import admin from 'firebase-admin';
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Initialize Firebase Admin SDK
const initializeFirebase = () => {
    try {
        // Check if already initialized
        if (admin.apps.length > 0) {
            return admin;
        }

        const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
            join(__dirname, 'serviceAccountKey.json');

        if (existsSync(serviceAccountPath)) {
            // Use service account JSON file
            const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));

            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                storageBucket: process.env.FIREBASE_STORAGE_BUCKET || 'islamic-app-backend.firebasestorage.app'
            });

            console.log('✅ Firebase Admin initialized with service account file');
        } else if (process.env.FIREBASE_PROJECT_ID) {
            // Use environment variables
            admin.initializeApp({
                credential: admin.credential.cert({
                    projectId: process.env.FIREBASE_PROJECT_ID,
                    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
                    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
                }),
            });

            console.log('✅ Firebase Admin initialized with environment variables');
        } else {
            throw new Error('No Firebase credentials found. Please provide serviceAccountKey.json or environment variables.');
        }

        return admin;
    } catch (error) {
        console.error('❌ Firebase initialization error:', error.message);
        throw error;
    }
};

// Initialize on import
initializeFirebase();

// Export Firestore and Auth instances
export const db = admin.firestore();
export const auth = admin.auth();
export { admin };
export default admin;

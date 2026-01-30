import express from 'express';
import admin from 'firebase-admin';
import whatsappService from '../utils/whatsappService.js';

const router = express.Router();
const db = admin.firestore();

// GET system settings (specifically WhatsApp)
router.get('/whatsapp', async (req, res) => {
    try {
        const doc = await db.collection('settings').doc('whatsapp').get();
        const settings = doc.exists ? doc.data() : { number: '03160212457' };

        const waStatus = await whatsappService.getStatus();

        res.json({
            success: true,
            settings,
            whatsapp: waStatus
        });
    } catch (error) {
        console.error('Error fetching settings:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST update WhatsApp number
router.post('/whatsapp', async (req, res) => {
    try {
        const { number } = req.body;
        if (!number) return res.status(400).json({ success: false, message: 'Number is required' });

        await db.collection('settings').doc('whatsapp').set({
            number,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });

        // If number changed, maybe we want to force a re-login? 
        // For now just update the stored number.

        res.json({ success: true, message: 'WhatsApp number updated successfully' });
    } catch (error) {
        console.error('Error updating settings:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST logout/reset WhatsApp
router.post('/whatsapp/reset', async (req, res) => {
    try {
        await whatsappService.logout();
        res.json({ success: true, message: 'WhatsApp session reset initiated' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

export default router;

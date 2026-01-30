import express from 'express';
import admin from 'firebase-admin';
import multer from 'multer';
import { uploadToSupabase } from '../config/supabase.js';
import whatsappService from '../utils/whatsappService.js';

const router = express.Router();
const db = admin.firestore();

const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 }
});

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

        // 1. Check if the number has actually changed
        const doc = await db.collection('settings').doc('whatsapp').get();
        const prevNumber = doc.exists ? doc.data().number : null;

        // 2. Save the new number
        await db.collection('settings').doc('whatsapp').set({
            number,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });

        // 3. If number changed, force a session reset to link the new one
        if (prevNumber && prevNumber !== number) {
            console.log(`[SYSTEM] WhatsApp number changed from ${prevNumber} to ${number}. Resetting session...`);
            await whatsappService.logout();
        }

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

// GET admin profile data (password, etc.)
router.get('/admin/profile-data', async (req, res) => {
    try {
        const doc = await db.collection('settings').doc('admin_profile').get();
        const data = doc.exists ? doc.data() : { password: 'adminpassword123' };
        res.json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST update admin profile data
router.post('/admin/profile-data', async (req, res) => {
    try {
        const data = req.body;
        await db.collection('settings').doc('admin_profile').set({
            ...data,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });
        res.json({ success: true, message: 'Admin profile data updated' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST upload admin profile image to Supabase
router.post('/admin/profile-image', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ success: false, message: 'No image provided' });

        const result = await uploadToSupabase(req.file.buffer, req.file.originalname, 'admin-profiles');

        if (result.error) throw new Error(result.error);

        res.json({ success: true, url: result.url });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

export default router;

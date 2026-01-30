import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// Get all donations
router.get('/', async (req, res) => {
    try {
        console.log('Fetching all donations...');
        const snapshot = await db.collection('donations').orderBy('timestamp', 'desc').get();

        const donations = [];
        snapshot.forEach((doc) => {
            donations.push({ id: doc.id, ...doc.data() });
        });

        res.json({ success: true, donations });
    } catch (error) {
        console.error('Error fetching donations:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// Get donation settings (Account details)
router.get('/settings', async (req, res) => {
    try {
        console.log('Fetching donation settings...');
        const docSnap = await db.collection('settings').doc('donations').get();

        if (docSnap.exists) {
            res.json({ success: true, settings: docSnap.data() });
        } else {
            console.log('No settings found, returning defaults');
            res.json({
                success: true,
                settings: {
                    'Bank Transfer': { Account: '', Number: '', Bank: '', IBAN: '' },
                    'PayPal': { Email: '' },
                    'Easypaisa': { Number: '', Name: '' },
                    'JazzCash': { Number: '', Name: '' }
                }
            });
        }
    } catch (error) {
        console.error('Error fetching settings:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// Update donation settings
router.post('/settings', async (req, res) => {
    try {
        console.log('Updating donation settings:', req.body);
        if (!req.body || Object.keys(req.body).length === 0) {
            return res.status(400).json({ success: false, message: 'Settings data is required' });
        }

        await db.collection('settings').doc('donations').set(req.body, { merge: true });
        res.json({ success: true, message: 'Settings updated successfully' });
    } catch (error) {
        console.error('Error updating settings:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// Update donation status
router.patch('/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        console.log(`Updating donation ${id} status to ${status}`);

        await db.collection('donations').doc(id).update({
            status,
            updatedAt: new Date()
        });
        res.json({ success: true, message: 'Status updated successfully' });
    } catch (error) {
        console.error('Error updating status:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// Delete donation
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        console.log('Deleting donation:', id);
        await db.collection('donations').doc(id).delete();
        res.json({ success: true, message: 'Donation record deleted' });
    } catch (error) {
        console.error('Error deleting donation:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

export default router;

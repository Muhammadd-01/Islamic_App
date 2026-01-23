import express from 'express';
import { db } from '../config/firebase.js';
import { sendPushNotification } from '../utils/onesignal.js';

const router = express.Router();

// Get today's unified inspiration
router.get('/today', async (req, res) => {
    try {
        const todayId = new Date().toISOString().split('T')[0];
        const doc = await db.collection('unified_inspirations').doc(todayId).get();

        if (!doc.exists) {
            return res.json({ message: 'No inspiration found for today' });
        }

        res.json(doc.data());
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch today\'s inspiration' });
    }
});

// Update or create inspiration part
router.post('/update', async (req, res) => {
    try {
        const { type, text, source, author } = req.body;
        const todayId = new Date().toISOString().split('T')[0];
        const docRef = db.collection('unified_inspirations').doc(todayId);

        const updateData = {};
        if (type === 'quote') updateData.quote = { text, author };
        if (type === 'hadith') updateData.hadith = { text, source };
        if (type === 'ayah') updateData.ayah = { text, source };

        updateData.updatedAt = new Date();

        await docRef.set(updateData, { merge: true });

        // Check if all three are now complete to send notification
        const finalDoc = await docRef.get();
        const data = finalDoc.data();

        if (data.quote && data.hadith && data.ayah && !data.notified) {
            // All 3 added! Send notification
            sendPushNotification({
                title: 'Daily Inspiration is Ready!',
                message: 'Check out today\'s Quote, Hadith, and Ayah on your home screen.',
                data: {
                    type: 'inspiration',
                    date: todayId
                }
            });

            await docRef.update({ notified: true });
        }

        res.json({ message: `${type} updated successfully`, data });
    } catch (error) {
        console.error('Error updating inspiration:', error);
        res.status(500).json({ error: 'Failed to update inspiration' });
    }
});

// Get history
router.get('/history', async (req, res) => {
    try {
        const snapshot = await db.collection('unified_inspirations')
            .orderBy('updatedAt', 'desc')
            .limit(10)
            .get();

        const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(items);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch history' });
    }
});

export default router;

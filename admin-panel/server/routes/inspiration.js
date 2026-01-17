import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// Get all daily inspirations
router.get('/', async (req, res) => {
    try {
        const { type } = req.query;
        let query = db.collection('daily_inspiration');
        if (type) {
            query = query.where('type', '==', type);
        }
        const snapshot = await query.orderBy('createdAt', 'desc').get();
        const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(items);
    } catch (error) {
        console.error('Error fetching inspirations:', error);
        res.status(500).json({ error: 'Failed to fetch inspirations' });
    }
});

// Get today's inspiration (rotating: quote -> hadith -> ayat)
router.get('/today', async (req, res) => {
    try {
        const today = new Date();
        const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / (1000 * 60 * 60 * 24));
        const types = ['quote', 'hadith', 'ayat'];
        const todayType = types[dayOfYear % 3];

        const snapshot = await db.collection('daily_inspiration')
            .where('type', '==', todayType)
            .limit(10)
            .get();

        if (snapshot.empty) {
            return res.json({ message: 'No inspiration found for today' });
        }

        const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        const randomIndex = dayOfYear % items.length;
        res.json({ type: todayType, inspiration: items[randomIndex] });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch today\'s inspiration' });
    }
});

// Create inspiration
router.post('/', async (req, res) => {
    try {
        const { type, arabic, translation, source, author } = req.body;
        if (!['quote', 'hadith', 'ayat'].includes(type)) {
            return res.status(400).json({ error: 'Type must be quote, hadith, or ayat' });
        }
        const docRef = await db.collection('daily_inspiration').add({
            type,
            arabic,
            translation,
            source,
            author,
            createdAt: new Date(),
            updatedAt: new Date()
        });
        res.status(201).json({ id: docRef.id, message: 'Inspiration created successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to create inspiration' });
    }
});

// Update inspiration
router.put('/:id', async (req, res) => {
    try {
        const { type, arabic, translation, source, author } = req.body;
        await db.collection('daily_inspiration').doc(req.params.id).update({
            type,
            arabic,
            translation,
            source,
            author,
            updatedAt: new Date()
        });
        res.json({ message: 'Inspiration updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update inspiration' });
    }
});

// Delete inspiration
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('daily_inspiration').doc(req.params.id).delete();
        res.json({ message: 'Inspiration deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete inspiration' });
    }
});

export default router;

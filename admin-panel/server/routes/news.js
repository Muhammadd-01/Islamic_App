import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();
const collection = 'news';

// Get all news
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection(collection).orderBy('createdAt', 'desc').get();
        const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(items);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Create news
router.post('/', async (req, res) => {
    try {
        const data = {
            ...req.body,
            createdAt: new Date().toISOString(),
        };
        const docRef = await db.collection(collection).add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update news
router.put('/:id', async (req, res) => {
    try {
        await db.collection(collection).doc(req.params.id).update(req.body);
        res.json({ id: req.params.id, ...req.body });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Delete news
router.delete('/:id', async (req, res) => {
    try {
        await db.collection(collection).doc(req.params.id).delete();
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;

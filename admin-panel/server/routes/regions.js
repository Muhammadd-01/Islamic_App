import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// Get all regions
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('regions').orderBy('name').get();
        const regions = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(regions);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch regions' });
    }
});

// Create region
router.post('/', async (req, res) => {
    try {
        const { name } = req.body;
        if (!name) return res.status(400).json({ error: 'Name is required' });

        const docRef = await db.collection('regions').add({ name });
        res.json({ id: docRef.id, name });
    } catch (error) {
        res.status(500).json({ error: 'Failed to create region' });
    }
});

// Delete region
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('regions').doc(req.params.id).delete();
        res.json({ message: 'Region deleted' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete region' });
    }
});

export default router;

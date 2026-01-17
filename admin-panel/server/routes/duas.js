import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// Get all Duas
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('duas').orderBy('category').get();
        const duas = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(duas);
    } catch (error) {
        console.error('Error fetching duas:', error);
        res.status(500).json({ error: 'Failed to fetch duas' });
    }
});

// Get single dua
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('duas').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Dua not found' });
        }
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch dua' });
    }
});

// Create dua
router.post('/', async (req, res) => {
    try {
        const { title, arabic, transliteration, translation, category, reference, benefits } = req.body;
        const docRef = await db.collection('duas').add({
            title,
            arabic,
            transliteration,
            translation,
            category,
            reference,
            benefits,
            createdAt: new Date(),
            updatedAt: new Date()
        });
        res.status(201).json({ id: docRef.id, message: 'Dua created successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to create dua' });
    }
});

// Update dua
router.put('/:id', async (req, res) => {
    try {
        const { title, arabic, transliteration, translation, category, reference, benefits } = req.body;
        await db.collection('duas').doc(req.params.id).update({
            title,
            arabic,
            transliteration,
            translation,
            category,
            reference,
            benefits,
            updatedAt: new Date()
        });
        res.json({ message: 'Dua updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update dua' });
    }
});

// Delete dua
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('duas').doc(req.params.id).delete();
        res.json({ message: 'Dua deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete dua' });
    }
});

export default router;

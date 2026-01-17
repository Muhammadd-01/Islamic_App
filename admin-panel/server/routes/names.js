import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// Get all 99 Names of Allah
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('names_of_allah').orderBy('number').get();
        const names = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(names);
    } catch (error) {
        console.error('Error fetching names:', error);
        res.status(500).json({ error: 'Failed to fetch names' });
    }
});

// Get single name
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('names_of_allah').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Name not found' });
        }
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch name' });
    }
});

// Create name
router.post('/', async (req, res) => {
    try {
        const { number, arabic, transliteration, meaning, description } = req.body;
        const docRef = await db.collection('names_of_allah').add({
            number,
            arabic,
            transliteration,
            meaning,
            description,
            createdAt: new Date(),
            updatedAt: new Date()
        });
        res.status(201).json({ id: docRef.id, message: 'Name created successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to create name' });
    }
});

// Update name
router.put('/:id', async (req, res) => {
    try {
        const { number, arabic, transliteration, meaning, description } = req.body;
        await db.collection('names_of_allah').doc(req.params.id).update({
            number,
            arabic,
            transliteration,
            meaning,
            description,
            updatedAt: new Date()
        });
        res.json({ message: 'Name updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update name' });
    }
});

// Delete name
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('names_of_allah').doc(req.params.id).delete();
        res.json({ message: 'Name deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete name' });
    }
});

export default router;

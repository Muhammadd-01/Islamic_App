import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();
const collection = 'azkar';

// Get all azkar
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection(collection).orderBy('name').get();
        const azkar = [];
        snapshot.forEach(doc => {
            azkar.push({ id: doc.id, ...doc.data() });
        });
        res.json(azkar);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Create azkar
router.post('/', async (req, res) => {
    try {
        const { name, arabic, meaning } = req.body;
        const docRef = await db.collection(collection).add({
            name,
            arabic,
            meaning,
            createdAt: new Date().toISOString()
        });
        res.status(201).json({ id: docRef.id });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update azkar
router.put('/:id', async (req, res) => {
    try {
        const { name, arabic, meaning } = req.body;
        await db.collection(collection).doc(req.params.id).update({
            name,
            arabic,
            meaning,
            updatedAt: new Date().toISOString()
        });
        res.json({ message: 'Azkar updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Delete azkar
router.delete('/:id', async (req, res) => {
    try {
        await db.collection(collection).doc(req.params.id).delete();
        res.json({ message: 'Azkar deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;

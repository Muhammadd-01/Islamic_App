import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// GET all scholars
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('scholars').get();
        const scholars = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        res.json(scholars);
    } catch (error) {
        console.error('Error fetching scholars:', error);
        res.status(500).json({ error: 'Failed to fetch scholars' });
    }
});

// GET single scholar
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('scholars').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Scholar not found' });
        }
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch scholar' });
    }
});

// POST create scholar
router.post('/', async (req, res) => {
    try {
        const { name, specialty, bio, imageUrl, isAvailableFor1on1, consultationFee } = req.body;
        const docRef = await db.collection('scholars').add({
            name,
            specialty,
            bio,
            imageUrl: imageUrl || '',
            isAvailableFor1on1: isAvailableFor1on1 || false,
            consultationFee: consultationFee || 0,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });
        res.status(201).json({ id: docRef.id, message: 'Scholar created successfully' });
    } catch (error) {
        console.error('Error creating scholar:', error);
        res.status(500).json({ error: 'Failed to create scholar' });
    }
});

// PUT update scholar
router.put('/:id', async (req, res) => {
    try {
        const { name, specialty, bio, imageUrl, isAvailableFor1on1, consultationFee } = req.body;
        await db.collection('scholars').doc(req.params.id).update({
            name,
            specialty,
            bio,
            imageUrl: imageUrl || '',
            isAvailableFor1on1: isAvailableFor1on1 || false,
            consultationFee: consultationFee || 0,
            updatedAt: new Date().toISOString()
        });
        res.json({ message: 'Scholar updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update scholar' });
    }
});

// DELETE scholar
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('scholars').doc(req.params.id).delete();
        res.json({ message: 'Scholar deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete scholar' });
    }
});

export default router;

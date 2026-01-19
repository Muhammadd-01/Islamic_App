import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// GET all beliefs
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('beliefs').get();
        const beliefs = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        res.json(beliefs);
    } catch (error) {
        console.error('Error fetching beliefs:', error);
        res.status(500).json({ error: 'Failed to fetch beliefs' });
    }
});

// GET single belief
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('beliefs').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Belief not found' });
        }
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch belief' });
    }
});

// POST create belief
router.post('/', async (req, res) => {
    try {
        const { name, description, category, contentType, videoUrl, documentUrl, imageUrl } = req.body;
        const docRef = await db.collection('beliefs').add({
            name,
            description,
            category: category || 'atheism',
            contentType: contentType || 'video',
            videoUrl: videoUrl || '',
            documentUrl: documentUrl || '',
            imageUrl: imageUrl || '',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });
        res.status(201).json({ id: docRef.id, message: 'Belief created successfully' });
    } catch (error) {
        console.error('Error creating belief:', error);
        res.status(500).json({ error: 'Failed to create belief' });
    }
});

// PUT update belief
router.put('/:id', async (req, res) => {
    try {
        const { name, description, category, contentType, videoUrl, documentUrl, imageUrl } = req.body;
        await db.collection('beliefs').doc(req.params.id).update({
            name,
            description,
            category: category || 'atheism',
            contentType: contentType || 'video',
            videoUrl: videoUrl || '',
            documentUrl: documentUrl || '',
            imageUrl: imageUrl || '',
            updatedAt: new Date().toISOString()
        });
        res.json({ message: 'Belief updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update belief' });
    }
});

// DELETE belief
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('beliefs').doc(req.params.id).delete();
        res.json({ message: 'Belief deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete belief' });
    }
});

export default router;

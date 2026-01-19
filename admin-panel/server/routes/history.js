import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// GET all history
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('history').get();
        const history = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        res.json(history);
    } catch (error) {
        console.error('Error fetching history:', error);
        res.status(500).json({ error: 'Failed to fetch history' });
    }
});

// GET single history item
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('history').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'History item not found' });
        }
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch history item' });
    }
});

// POST create history
router.post('/', async (req, res) => {
    try {
        const { title, description, era, category, contentType, videoUrl, documentUrl, imageUrl } = req.body;
        const docRef = await db.collection('history').add({
            title,
            description,
            era,
            category: category || 'islamic',
            contentType: contentType || 'video',
            videoUrl: videoUrl || '',
            documentUrl: documentUrl || '',
            imageUrl: imageUrl || '',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });
        res.status(201).json({ id: docRef.id, message: 'History created successfully' });
    } catch (error) {
        console.error('Error creating history:', error);
        res.status(500).json({ error: 'Failed to create history' });
    }
});

// PUT update history
router.put('/:id', async (req, res) => {
    try {
        const { title, description, era, category, contentType, videoUrl, documentUrl, imageUrl } = req.body;
        await db.collection('history').doc(req.params.id).update({
            title,
            description,
            era,
            category: category || 'islamic',
            contentType: contentType || 'video',
            videoUrl: videoUrl || '',
            documentUrl: documentUrl || '',
            imageUrl: imageUrl || '',
            updatedAt: new Date().toISOString()
        });
        res.json({ message: 'History updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update history' });
    }
});

// DELETE history
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('history').doc(req.params.id).delete();
        res.json({ message: 'History deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete history' });
    }
});

export default router;

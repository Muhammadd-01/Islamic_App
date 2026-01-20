import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// GET all religions
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('religions').get();
        const religions = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        res.json(religions);
    } catch (error) {
        console.error('Error fetching religions:', error);
        res.status(500).json({ error: 'Failed to fetch religions' });
    }
});

// GET single religion
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('religions').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Religion not found' });
        }
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch religion' });
    }
});

// POST create religion
router.post('/', async (req, res) => {
    try {
        const { name, description, icon, color, displaySection, contentType, videoUrl, documentUrl, imageUrl } = req.body;
        const docRef = await db.collection('religions').add({
            name,
            description,
            icon: icon || '',
            color: color || '#3B82F6',
            displaySection: displaySection || 'major',
            contentType: contentType || 'video',
            videoUrl: videoUrl || '',
            documentUrl: documentUrl || '',
            imageUrl: imageUrl || '',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });
        res.status(201).json({ id: docRef.id, message: 'Religion created successfully' });
    } catch (error) {
        console.error('Error creating religion:', error);
        res.status(500).json({ error: 'Failed to create religion' });
    }
});

// PUT update religion
router.put('/:id', async (req, res) => {
    try {
        const { name, description, icon, color, displaySection, contentType, videoUrl, documentUrl, imageUrl } = req.body;
        await db.collection('religions').doc(req.params.id).update({
            name,
            description,
            icon: icon || '',
            color: color || '#3B82F6',
            displaySection: displaySection || 'major',
            contentType: contentType || 'video',
            videoUrl: videoUrl || '',
            documentUrl: documentUrl || '',
            imageUrl: imageUrl || '',
            updatedAt: new Date().toISOString()
        });
        res.json({ message: 'Religion updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update religion' });
    }
});

// DELETE religion
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('religions').doc(req.params.id).delete();
        res.json({ message: 'Religion deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete religion' });
    }
});

export default router;

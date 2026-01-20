import express from 'express';
import multer from 'multer';
import { db } from '../config/firebase.js';
import { uploadToSupabase } from '../config/supabase.js';

const router = express.Router();

// Multer config
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

// Upload helper
const uploadFile = async (file, bucket = 'history-images') => {
    const result = await uploadToSupabase(file.buffer, file.originalname, bucket);
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

// GET all history
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('history').orderBy('title').get(); // Added ordering
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
router.post('/', upload.fields([{ name: 'image', maxCount: 1 }, { name: 'document', maxCount: 1 }]), async (req, res) => {
    try {
        const { title, description, era, category, displayMode, contentType, videoUrl, documentUrl, imageUrl } = req.body;

        let finalImageUrl = imageUrl || '';
        let finalDocumentUrl = documentUrl || '';

        if (req.files) {
            if (req.files.image) {
                finalImageUrl = await uploadFile(req.files.image[0], 'history-images');
            }
            if (req.files.document) {
                finalDocumentUrl = await uploadFile(req.files.document[0], 'history-images');
            }
        }

        const docRef = await db.collection('history').add({
            title,
            description,
            era,
            category: category || 'islamic',
            displayMode: displayMode || 'browse',
            contentType: contentType || 'video',
            videoUrl: videoUrl || '',
            documentUrl: finalDocumentUrl,
            imageUrl: finalImageUrl,
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
router.put('/:id', upload.fields([{ name: 'image', maxCount: 1 }, { name: 'document', maxCount: 1 }]), async (req, res) => {
    try {
        const { title, description, era, category, displayMode, contentType, videoUrl, documentUrl, imageUrl } = req.body;

        const updateData = {
            updatedAt: new Date().toISOString()
        };

        if (title) updateData.title = title;
        if (description) updateData.description = description;
        if (era) updateData.era = era;
        if (category) updateData.category = category;
        if (displayMode) updateData.displayMode = displayMode;
        if (contentType) updateData.contentType = contentType;
        if (videoUrl !== undefined) updateData.videoUrl = videoUrl;
        if (documentUrl !== undefined) updateData.documentUrl = documentUrl;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;

        if (req.files) {
            if (req.files.image) {
                updateData.imageUrl = await uploadFile(req.files.image[0], 'history-images');
            }
            if (req.files.document) {
                updateData.documentUrl = await uploadFile(req.files.document[0], 'history-images');
            }
        }

        await db.collection('history').doc(req.params.id).update(updateData);
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

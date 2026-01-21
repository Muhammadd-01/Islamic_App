import express from 'express';
import multer from 'multer';
import { db } from '../config/firebase.js';
import { uploadToSupabase } from '../config/supabase.js';

const router = express.Router();
const collection = 'news';

// Multer config
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// Upload helper
const uploadImage = async (file) => {
    const result = await uploadToSupabase(file.buffer, file.originalname, 'news-images');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

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
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { title, content, author, source, imageUrl } = req.body;

        let finalImageUrl = imageUrl || '';
        if (req.file) {
            finalImageUrl = await uploadImage(req.file);
        }

        const data = {
            title,
            content,
            author,
            source,
            category: req.body.category || 'general',
            imageUrl: finalImageUrl,
            videoUrl: req.body.videoUrl || '', // Add these
            documentUrl: req.body.documentUrl || '', // for App compatibility
            publishedAt: new Date().toISOString(), // Add this for App compatibility
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        const docRef = await db.collection(collection).add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update news
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { title, content, author, source, imageUrl } = req.body;

        const updateData = {
            updatedAt: new Date().toISOString()
        };

        if (title) updateData.title = title;
        if (content) updateData.content = content;
        if (author) updateData.author = author;
        if (source) updateData.source = source;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;

        if (req.file) {
            updateData.imageUrl = await uploadImage(req.file);
        }

        await db.collection(collection).doc(req.params.id).update(updateData);
        res.json({ id: req.params.id, ...updateData });
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

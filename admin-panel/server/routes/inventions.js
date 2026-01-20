import express from 'express';
import multer from 'multer';
import { db } from '../config/firebase.js';
import { uploadToSupabase } from '../config/supabase.js';

const router = express.Router();

// Multer config
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// Upload helper
const uploadImage = async (file) => {
    const result = await uploadToSupabase(file.buffer, file.originalname, 'invention-images');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

// GET all
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('inventions').orderBy('year').get();
        const inventions = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json({ inventions });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('inventions').doc(req.params.id).get();
        if (!doc.exists) return res.status(404).json({ error: 'Invention not found' });
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// CREATE
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { title, description, discoveredBy, refinedBy, year, details, category, contentType } = req.body;
        let imageUrl = req.body.imageUrl || '';

        if (req.file) {
            imageUrl = await uploadImage(req.file);
        }

        // Details should be array, might come as string from form
        let parsedDetails = [];
        if (typeof details === 'string') {
            try { parsedDetails = JSON.parse(details); } catch (e) { parsedDetails = [details]; }
        } else if (Array.isArray(details)) {
            parsedDetails = details;
        }

        const data = {
            title,
            description,
            discoveredBy,
            refinedBy,
            year: year || '',
            imageUrl,
            details: parsedDetails,
            category: category || 'muslim',
            contentType: contentType || 'document',
            createdAt: new Date(),
            updatedAt: new Date()
        };

        const docRef = await db.collection('inventions').add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (error) {
        console.error('Error creating invention:', error);
        console.error('Stack:', error.stack);
        if (error.message && error.message.includes('Supabase')) {
            return res.status(500).json({
                error: 'Image upload failed',
                message: error.message,
                suggestion: 'Check server SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY'
            });
        }
        res.status(500).json({ error: 'Failed to create invention', message: error.message, stack: error.stack });
    }
});

// UPDATE
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { title, description, discoveredBy, refinedBy, year, details, category, contentType } = req.body;
        let imageUrl = req.body.imageUrl;

        if (req.file) {
            imageUrl = await uploadImage(req.file);
        }

        let parsedDetails;
        if (details) {
            if (typeof details === 'string') {
                try { parsedDetails = JSON.parse(details); } catch (e) { parsedDetails = [details]; }
            } else if (Array.isArray(details)) {
                parsedDetails = details;
            }
        }

        const updateData = { updatedAt: new Date() };
        if (title) updateData.title = title;
        if (description) updateData.description = description;
        if (discoveredBy) updateData.discoveredBy = discoveredBy;
        if (refinedBy) updateData.refinedBy = refinedBy;
        if (year) updateData.year = year;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
        if (parsedDetails) updateData.details = parsedDetails;
        if (category) updateData.category = category;
        if (contentType) updateData.contentType = contentType;

        await db.collection('inventions').doc(req.params.id).update(updateData);
        res.json({ message: 'Updated successfully', id: req.params.id });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

// DELETE
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('inventions').doc(req.params.id).delete();
        res.json({ message: 'Deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;

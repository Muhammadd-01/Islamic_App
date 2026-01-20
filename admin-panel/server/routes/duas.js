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
    const result = await uploadToSupabase(file.buffer, file.originalname, 'dua-images');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

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
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { title, arabic, transliteration, translation, category, reference, benefits, imageUrl } = req.body;

        let finalImageUrl = imageUrl || '';
        if (req.file) {
            finalImageUrl = await uploadImage(req.file);
        }

        const docRef = await db.collection('duas').add({
            title,
            arabic,
            transliteration,
            translation,
            category,
            reference,
            benefits,
            imageUrl: finalImageUrl,
            createdAt: new Date(),
            updatedAt: new Date()
        });
        res.status(201).json({ id: docRef.id, message: 'Dua created successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to create dua' });
    }
});

// Update dua
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { title, arabic, transliteration, translation, category, reference, benefits, imageUrl } = req.body;

        const updateData = {
            updatedAt: new Date()
        };

        if (title) updateData.title = title;
        if (arabic) updateData.arabic = arabic;
        if (transliteration) updateData.transliteration = transliteration;
        if (translation) updateData.translation = translation;
        if (category) updateData.category = category;
        if (reference) updateData.reference = reference;
        if (benefits) updateData.benefits = benefits;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;

        if (req.file) {
            updateData.imageUrl = await uploadImage(req.file);
        }

        await db.collection('duas').doc(req.params.id).update(updateData);
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

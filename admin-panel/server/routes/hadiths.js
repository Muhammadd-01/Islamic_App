import express from 'express';
import multer from 'multer';
import { db } from '../config/firebase.js';
import { uploadToSupabase } from '../config/supabase.js';

const router = express.Router();
const collection = 'hadiths';

// Multer config
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// Upload helper
const uploadImage = async (file) => {
    const result = await uploadToSupabase(file.buffer, file.originalname, 'hadith-images');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

// Get all hadiths
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection(collection).orderBy('createdAt', 'desc').get();
        const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(items);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Create hadith
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { title, content, narrator, book, chapter, grade, imageUrl } = req.body;

        let finalImageUrl = imageUrl || '';
        if (req.file) {
            finalImageUrl = await uploadImage(req.file);
        }

        const data = {
            title,
            content,
            narrator,
            book,
            chapter,
            grade,
            imageUrl: finalImageUrl,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        const docRef = await db.collection(collection).add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update hadith
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { title, content, narrator, book, chapter, grade, imageUrl } = req.body;

        const updateData = {
            updatedAt: new Date().toISOString()
        };

        if (title) updateData.title = title;
        if (content) updateData.content = content;
        if (narrator) updateData.narrator = narrator;
        if (book) updateData.book = book;
        if (chapter) updateData.chapter = chapter;
        if (grade) updateData.grade = grade;
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

// Delete hadith
router.delete('/:id', async (req, res) => {
    try {
        await db.collection(collection).doc(req.params.id).delete();
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;

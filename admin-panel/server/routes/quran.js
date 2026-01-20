import express from 'express';
import multer from 'multer';
import { db } from '../config/firebase.js';
import { uploadToSupabase } from '../config/supabase.js';

const router = express.Router();
const collection = 'quran';

// Multer config
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// Upload helper
const uploadImage = async (file) => {
    const result = await uploadToSupabase(file.buffer, file.originalname, 'quran-images');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

// Get all quran entries
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection(collection).orderBy('surahNumber').get();
        const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(items);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Create quran entry (Surah or Ayah)
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { surahName, surahNumber, ayahs, revelationType, description, imageUrl, audioUrl } = req.body;

        let finalImageUrl = imageUrl || '';
        if (req.file) {
            finalImageUrl = await uploadImage(req.file);
        }

        const data = {
            surahName,
            surahNumber: parseInt(surahNumber),
            ayahs: parseInt(ayahs),
            revelationType: revelationType || 'Meccan',
            description,
            imageUrl: finalImageUrl,
            audioUrl: audioUrl || '',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        const docRef = await db.collection(collection).add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update quran entry
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { surahName, surahNumber, ayahs, revelationType, description, imageUrl, audioUrl } = req.body;

        const updateData = {
            updatedAt: new Date().toISOString()
        };

        if (surahName) updateData.surahName = surahName;
        if (surahNumber) updateData.surahNumber = parseInt(surahNumber);
        if (ayahs) updateData.ayahs = parseInt(ayahs);
        if (revelationType) updateData.revelationType = revelationType;
        if (description) updateData.description = description;
        if (audioUrl !== undefined) updateData.audioUrl = audioUrl;
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

// Delete quran entry
router.delete('/:id', async (req, res) => {
    try {
        await db.collection(collection).doc(req.params.id).delete();
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;

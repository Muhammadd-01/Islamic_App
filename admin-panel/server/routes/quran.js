import express from 'express';
import multer from 'multer';
import { db } from '../config/firebase.js';
import { uploadToSupabase } from '../config/supabase.js';

const router = express.Router();
const collection = 'quran';

// Multer config
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 50 * 1024 * 1024 } // 50MB for audio/pdf
});

// Upload helper
const uploadFile = async (file, bucket) => {
    const result = await uploadToSupabase(file.buffer, file.originalname, bucket);
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
router.post('/', upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'pdf', maxCount: 1 },
    { name: 'audio', maxCount: 1 }
]), async (req, res) => {
    try {
        const { surahName, surahNumber, ayahs, revelationType, description, imageUrl, audioUrl, pdfUrl, translation } = req.body;

        let finalImageUrl = imageUrl || '';
        let finalPdfUrl = pdfUrl || '';
        let finalAudioUrl = audioUrl || '';

        if (req.files) {
            if (req.files['image']) {
                finalImageUrl = await uploadFile(req.files['image'][0], 'quran-images');
            }
            if (req.files['pdf']) {
                finalPdfUrl = await uploadFile(req.files['pdf'][0], 'quran-pdfs');
            }
            if (req.files['audio']) {
                finalAudioUrl = await uploadFile(req.files['audio'][0], 'quran-recitations');
            }
        }

        const data = {
            surahName,
            surahNumber: parseInt(surahNumber),
            ayahs: parseInt(ayahs),
            revelationType: revelationType || 'Meccan',
            description,
            imageUrl: finalImageUrl,
            pdfUrl: finalPdfUrl,
            audioUrl: finalAudioUrl,
            translation: translation || '',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        const docRef = await db.collection(collection).add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (error) {
        console.error('Error in Quran POST:', error);
        res.status(500).json({ error: error.message });
    }
});

// Update quran entry
router.put('/:id', upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'pdf', maxCount: 1 },
    { name: 'audio', maxCount: 1 }
]), async (req, res) => {
    try {
        const { surahName, surahNumber, ayahs, revelationType, description, imageUrl, audioUrl, pdfUrl, translation } = req.body;

        const updateData = {
            updatedAt: new Date().toISOString()
        };

        if (surahName) updateData.surahName = surahName;
        if (surahNumber) updateData.surahNumber = parseInt(surahNumber);
        if (ayahs) updateData.ayahs = parseInt(ayahs);
        if (revelationType) updateData.revelationType = revelationType;
        if (description) updateData.description = description;
        if (translation !== undefined) updateData.translation = translation;
        if (audioUrl !== undefined) updateData.audioUrl = audioUrl;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
        if (pdfUrl !== undefined) updateData.pdfUrl = pdfUrl;

        if (req.files) {
            if (req.files['image']) {
                updateData.imageUrl = await uploadFile(req.files['image'][0], 'quran-images');
            }
            if (req.files['pdf']) {
                updateData.pdfUrl = await uploadFile(req.files['pdf'][0], 'quran-pdfs');
            }
            if (req.files['audio']) {
                updateData.audioUrl = await uploadFile(req.files['audio'][0], 'quran-recitations');
            }
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

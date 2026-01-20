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
    const result = await uploadToSupabase(file.buffer, file.originalname, 'scholar-images');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

// GET all scholars
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('scholars').get();
        const scholars = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        res.json(scholars);
    } catch (error) {
        console.error('Error fetching scholars:', error);
        res.status(500).json({ error: 'Failed to fetch scholars' });
    }
});

// GET single scholar
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('scholars').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Scholar not found' });
        }
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch scholar' });
    }
});

// POST create scholar
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { name, specialty, bio, imageUrl, isAvailableFor1on1, consultationFee } = req.body;

        let finalImageUrl = imageUrl || '';
        if (req.file) {
            finalImageUrl = await uploadImage(req.file);
        }

        const docRef = await db.collection('scholars').add({
            name,
            specialty,
            bio,
            imageUrl: finalImageUrl,
            isAvailableFor1on1: isAvailableFor1on1 === 'true' || isAvailableFor1on1 === true,
            consultationFee: parseFloat(consultationFee) || 0,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });
        res.status(201).json({ id: docRef.id, message: 'Scholar created successfully' });
    } catch (error) {
        console.error('Error creating scholar:', error);
        res.status(500).json({ error: 'Failed to create scholar' });
    }
});

// PUT update scholar
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { name, specialty, bio, imageUrl, isAvailableFor1on1, consultationFee } = req.body;

        const updateData = {
            updatedAt: new Date().toISOString()
        };

        if (name) updateData.name = name;
        if (specialty) updateData.specialty = specialty;
        if (bio) updateData.bio = bio;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
        if (isAvailableFor1on1 !== undefined) updateData.isAvailableFor1on1 = isAvailableFor1on1 === 'true' || isAvailableFor1on1 === true;
        if (consultationFee !== undefined) updateData.consultationFee = parseFloat(consultationFee);

        if (req.file) {
            updateData.imageUrl = await uploadImage(req.file);
        }

        await db.collection('scholars').doc(req.params.id).update(updateData);
        res.json({ message: 'Scholar updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update scholar' });
    }
});

// DELETE scholar
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('scholars').doc(req.params.id).delete();
        res.json({ message: 'Scholar deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete scholar' });
    }
});

export default router;

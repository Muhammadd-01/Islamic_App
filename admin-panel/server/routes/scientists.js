import express from 'express';
import multer from 'multer';
import { db } from '../config/firebase.js';
import { uploadToSupabase } from '../config/supabase.js';

const router = express.Router();

// Multer config for memory storage
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// Helper to upload to Supabase
const uploadImage = async (file) => {
    const result = await uploadToSupabase(file.buffer, file.originalname, 'scientist-images');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

// GET all scientists
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('scientists').orderBy('name').get();
        const scientists = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json({ scientists });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single scientist
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('scientists').doc(req.params.id).get();
        if (!doc.exists) return res.status(404).json({ error: 'Scientist not found' });
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// CREATE scientist
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { name, bio, field, birthDeath, achievements, category, contentType } = req.body;
        let imageUrl = req.body.imageUrl || '';

        if (req.file) {
            imageUrl = await uploadImage(req.file);
        }

        let parsedAchievements = [];
        if (typeof achievements === 'string') {
            try { parsedAchievements = JSON.parse(achievements); } catch (e) { parsedAchievements = [achievements]; }
        } else if (Array.isArray(achievements)) {
            parsedAchievements = achievements;
        }

        const data = {
            name,
            bio,
            field,
            birthDeath,
            imageUrl,
            achievements: parsedAchievements,
            category: category || 'muslim', // Default to muslim
            contentType: contentType || 'document', // Default to document
            createdAt: new Date(),
            updatedAt: new Date()
        };

        const docRef = await db.collection('scientists').add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

// UPDATE scientist
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { name, bio, field, birthDeath, achievements, category, contentType } = req.body;
        let imageUrl = req.body.imageUrl;

        if (req.file) {
            imageUrl = await uploadImage(req.file);
        }

        let parsedAchievements;
        if (achievements) {
            if (typeof achievements === 'string') {
                try { parsedAchievements = JSON.parse(achievements); } catch (e) { parsedAchievements = [achievements]; }
            } else if (Array.isArray(achievements)) {
                parsedAchievements = achievements;
            }
        }

        const updateData = { updatedAt: new Date() };
        if (name) updateData.name = name;
        if (bio) updateData.bio = bio;
        if (field) updateData.field = field;
        if (birthDeath) updateData.birthDeath = birthDeath;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
        if (parsedAchievements) updateData.achievements = parsedAchievements;
        if (category) updateData.category = category;
        if (contentType) updateData.contentType = contentType;

        await db.collection('scientists').doc(req.params.id).update(updateData);
        res.json({ message: 'Updated successfully', id: req.params.id });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

// DELETE scientist
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('scientists').doc(req.params.id).delete();
        res.json({ message: 'Deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;

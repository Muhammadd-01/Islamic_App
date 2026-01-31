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
    const result = await uploadToSupabase(file.buffer, file.originalname, 'course-images');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

// GET all courses
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('courses').get();
        const courses = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        res.json(courses);
    } catch (error) {
        console.error('Error fetching courses:', error);
        res.status(500).json({ error: 'Failed to fetch courses' });
    }
});

// GET single course
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('courses').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Course not found' });
        }
        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch course' });
    }
});

// POST create course
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { title, description, instructor, duration, level, imageUrl, enrollUrl, isFree, price, minAge, academicCriteria, hasCertification } = req.body;

        let finalImageUrl = imageUrl || '';
        if (req.file) {
            finalImageUrl = await uploadImage(req.file);
        }

        const docRef = await db.collection('courses').add({
            title,
            description,
            instructor,
            duration,
            level: level || 'Beginner',
            imageUrl: finalImageUrl,
            enrollUrl: enrollUrl || '',
            isFree: isFree === 'true' || isFree === true,
            price: parseFloat(price) || 0,
            minAge: parseInt(minAge) || 0,
            academicCriteria: academicCriteria || '',
            hasCertification: hasCertification === 'true' || hasCertification === true,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });
        res.status(201).json({ id: docRef.id, message: 'Course created successfully' });
    } catch (error) {
        console.error('Error creating course:', error);
        res.status(500).json({ error: 'Failed to create course' });
    }
});

// PUT update course
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { title, description, instructor, duration, level, imageUrl, enrollUrl, isFree, price, minAge, academicCriteria, hasCertification } = req.body;

        const updateData = {
            updatedAt: new Date().toISOString()
        };

        if (title) updateData.title = title;
        if (description) updateData.description = description;
        if (instructor) updateData.instructor = instructor;
        if (duration) updateData.duration = duration;
        if (level) updateData.level = level;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
        if (enrollUrl !== undefined) updateData.enrollUrl = enrollUrl;
        if (isFree !== undefined) updateData.isFree = isFree === 'true' || isFree === true;
        if (price !== undefined) updateData.price = parseFloat(price);
        if (minAge !== undefined) updateData.minAge = parseInt(minAge);
        if (academicCriteria !== undefined) updateData.academicCriteria = academicCriteria;
        if (hasCertification !== undefined) updateData.hasCertification = hasCertification === 'true' || hasCertification === true;

        if (req.file) {
            updateData.imageUrl = await uploadImage(req.file);
        }

        await db.collection('courses').doc(req.params.id).update(updateData);
        res.json({ message: 'Course updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update course' });
    }
});

// DELETE course
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('courses').doc(req.params.id).delete();
        res.json({ message: 'Course deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete course' });
    }
});

export default router;

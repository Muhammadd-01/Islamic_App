import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

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
router.post('/', async (req, res) => {
    try {
        const { title, description, instructor, duration, level, imageUrl, enrollUrl, isFree, price } = req.body;
        const docRef = await db.collection('courses').add({
            title,
            description,
            instructor,
            duration,
            level: level || 'Beginner',
            imageUrl: imageUrl || '',
            enrollUrl: enrollUrl || '',
            isFree: isFree || false,
            price: price || 0,
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
router.put('/:id', async (req, res) => {
    try {
        const { title, description, instructor, duration, level, imageUrl, enrollUrl, isFree, price } = req.body;
        await db.collection('courses').doc(req.params.id).update({
            title,
            description,
            instructor,
            duration,
            level: level || 'Beginner',
            imageUrl: imageUrl || '',
            enrollUrl: enrollUrl || '',
            isFree: isFree || false,
            price: price || 0,
            updatedAt: new Date().toISOString()
        });
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

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
    const result = await uploadToSupabase(file.buffer, file.originalname, 'book-covers');
    if (result.error) {
        throw new Error(result.error);
    }
    return result.url;
};

// Get all books
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('books')
            .orderBy('createdAt', 'desc')
            .get();

        const books = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt?.toDate?.() || doc.data().createdAt,
        }));

        res.json({ books, total: books.length });
    } catch (error) {
        console.error('Error fetching books:', error);
        res.status(500).json({ error: 'Failed to fetch books', message: error.message });
    }
});

// Get single book
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('books').doc(req.params.id).get();

        if (!doc.exists) {
            return res.status(404).json({ error: 'Book not found' });
        }

        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        console.error('Error fetching book:', error);
        res.status(500).json({ error: 'Failed to fetch book', message: error.message });
    }
});

// Create new book
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { title, author, description, price, isFree, rating } = req.body;
        let coverUrl = req.body.coverUrl || ''; // URL from text input if any

        if (req.file) {
            coverUrl = await uploadImage(req.file);
        }

        if (!title || !author) {
            return res.status(400).json({ error: 'Title and author are required' });
        }

        const bookData = {
            title,
            author,
            description: description || '',
            coverUrl: coverUrl,
            price: parseFloat(price) || 0,
            isFree: isFree === 'true' || isFree === true, // Handle form-data string boolean
            rating: parseFloat(rating) || 0,
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        const docRef = await db.collection('books').add(bookData);

        res.status(201).json({
            message: 'Book created successfully',
            id: docRef.id,
            ...bookData
        });
    } catch (error) {
        console.error('Error creating book:', error);
        console.error('Stack:', error.stack);
        // Check if it's a Supabase error
        if (error.message && error.message.includes('Supabase')) {
            return res.status(500).json({
                error: 'Image upload failed',
                message: error.message,
                suggestion: 'Check server SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY'
            });
        }
        res.status(500).json({ error: 'Failed to create book', message: error.message, stack: error.stack });
    }
});

// Update book
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const { title, author, description, price, isFree, rating } = req.body;
        let coverUrl = req.body.coverUrl;

        if (req.file) {
            coverUrl = await uploadImage(req.file);
        }

        const updateData = {
            updatedAt: new Date(),
        };

        if (title) updateData.title = title;
        if (author) updateData.author = author;
        if (description !== undefined) updateData.description = description;
        if (coverUrl !== undefined) updateData.coverUrl = coverUrl;
        if (price !== undefined) updateData.price = parseFloat(price);
        if (isFree !== undefined) updateData.isFree = isFree === 'true' || isFree === true;
        if (rating !== undefined) updateData.rating = parseFloat(rating);

        await db.collection('books').doc(req.params.id).update(updateData);

        res.json({ message: 'Book updated successfully', id: req.params.id });
    } catch (error) {
        console.error('Error updating book:', error);
        res.status(500).json({ error: 'Failed to update book', message: error.message });
    }
});

// Delete book
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('books').doc(req.params.id).delete();
        res.json({ message: 'Book deleted successfully' });
    } catch (error) {
        console.error('Error deleting book:', error);
        res.status(500).json({ error: 'Failed to delete book', message: error.message });
    }
});

export default router;

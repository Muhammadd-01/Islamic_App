import express from 'express';
import multer from 'multer';
import { db, admin } from '../config/firebase.js';

const router = express.Router();

// Multer config
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// Upload helper
const uploadImage = async (file) => {
    const bucket = admin.storage().bucket();
    const filename = `inventions/${Date.now()}_${file.originalname.replace(/\s+/g, '_')}`;
    const fileUpload = bucket.file(filename);

    const stream = fileUpload.createWriteStream({
        metadata: { contentType: file.mimetype }
    });

    return new Promise((resolve, reject) => {
        stream.on('error', (err) => reject(err));
        stream.on('finish', async () => {
            await fileUpload.makePublic();
            resolve(`https://storage.googleapis.com/${bucket.name}/${filename}`);
        });
        stream.end(file.buffer);
    });
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

// CREATE
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { title, description, discoveredBy, refinedBy, year, details } = req.body;
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
            title, description, discoveredBy, refinedBy, year: year || '', imageUrl, details: parsedDetails
        };

        const docRef = await db.collection('inventions').add(data);
        res.status(201).json({ id: docRef.id, ...data });
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

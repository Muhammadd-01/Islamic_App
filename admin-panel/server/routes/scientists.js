import express from 'express';
import multer from 'multer';
import { db, admin } from '../config/firebase.js';

const router = express.Router();

const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 }
});

const uploadImage = async (file) => {
    const bucket = admin.storage().bucket();
    const filename = `scientists/${Date.now()}_${file.originalname.replace(/\s+/g, '_')}`;
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

router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('scientists').orderBy('name').get();
        const scientists = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json({ scientists });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { name, bio, field, birthDeath, achievements } = req.body;
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
            name, bio, field, birthDeath, imageUrl, achievements: parsedAchievements
        };

        const docRef = await db.collection('scientists').add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        await db.collection('scientists').doc(req.params.id).delete();
        res.json({ message: 'Deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;

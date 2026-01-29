import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// Get all tasbeeh stats with user info
router.get('/', async (req, res) => {
    try {
        const { limit = 50, offset = 0 } = req.query;

        const statsSnapshot = await db.collection('tasbeeh_stats')
            .orderBy('totalCount', 'desc')
            .limit(parseInt(limit))
            .offset(parseInt(offset))
            .get();

        const stats = [];

        // Use Promise.all to fetch user details for each stat entry
        const userPromises = [];

        statsSnapshot.forEach(doc => {
            const data = doc.data();
            const entry = {
                id: doc.id,
                ...data,
                lastUpdated: data.lastUpdated?.toDate?.() || data.lastUpdated,
            };
            stats.push(entry);
            userPromises.push(db.collection('users').doc(doc.id).get());
        });

        const userSnapshots = await Promise.all(userPromises);

        const statsWithUsers = stats.map((stat, index) => {
            const userDoc = userSnapshots[index];
            const userData = userDoc.exists ? userDoc.data() : null;
            return {
                ...stat,
                userName: userData?.name || 'Unknown User',
                userEmail: userData?.email || 'N/A',
                userImage: userData?.imageUrl || null,
            };
        });

        const totalSnapshot = await db.collection('tasbeeh_stats').count().get();
        const total = totalSnapshot.data().count;

        res.json({
            stats: statsWithUsers,
            total,
            limit: parseInt(limit),
            offset: parseInt(offset),
        });
    } catch (error) {
        console.error('Error fetching tasbeeh stats:', error);
        res.status(500).json({ error: 'Failed to fetch tasbeeh stats', message: error.message });
    }
});

export default router;

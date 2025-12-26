import express from 'express';
import { db, auth } from '../config/firebase.js';

const router = express.Router();

// Get all users
router.get('/', async (req, res) => {
    try {
        const { limit = 50, offset = 0, search = '' } = req.query;

        let query = db.collection('users').orderBy('createdAt', 'desc');

        const snapshot = await query.limit(parseInt(limit)).offset(parseInt(offset)).get();

        const users = [];
        snapshot.forEach(doc => {
            const data = doc.data();
            users.push({
                id: doc.id,
                ...data,
                createdAt: data.createdAt?.toDate?.() || data.createdAt,
                updatedAt: data.updatedAt?.toDate?.() || data.updatedAt,
            });
        });

        // Filter by search if provided
        const filteredUsers = search
            ? users.filter(u =>
                u.name?.toLowerCase().includes(search.toLowerCase()) ||
                u.email?.toLowerCase().includes(search.toLowerCase())
            )
            : users;

        // Get total count
        const countSnapshot = await db.collection('users').count().get();
        const total = countSnapshot.data().count;

        res.json({
            users: filteredUsers,
            total,
            limit: parseInt(limit),
            offset: parseInt(offset),
        });
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ error: 'Failed to fetch users', message: error.message });
    }
});

// Get single user
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('users').doc(req.params.id).get();

        if (!doc.exists) {
            return res.status(404).json({ error: 'User not found' });
        }

        const data = doc.data();
        res.json({
            id: doc.id,
            ...data,
            createdAt: data.createdAt?.toDate?.() || data.createdAt,
            updatedAt: data.updatedAt?.toDate?.() || data.updatedAt,
        });
    } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ error: 'Failed to fetch user', message: error.message });
    }
});

// Update user role
router.patch('/:id/role', async (req, res) => {
    try {
        const { role } = req.body;

        if (!['user', 'admin'].includes(role)) {
            return res.status(400).json({ error: 'Invalid role. Must be "user" or "admin"' });
        }

        await db.collection('users').doc(req.params.id).update({
            role,
            updatedAt: new Date(),
        });

        res.json({ message: 'User role updated successfully', role });
    } catch (error) {
        console.error('Error updating user role:', error);
        res.status(500).json({ error: 'Failed to update user role', message: error.message });
    }
});

// Delete user
router.delete('/:id', async (req, res) => {
    try {
        const userId = req.params.id;

        // Delete from Firestore
        await db.collection('users').doc(userId).delete();

        // Also delete user's cart
        await db.collection('carts').doc(userId).delete();

        // Delete from Firebase Auth
        try {
            await auth.deleteUser(userId);
        } catch (authError) {
            console.warn('Could not delete from Firebase Auth:', authError.message);
        }

        res.json({ message: 'User deleted successfully' });
    } catch (error) {
        console.error('Error deleting user:', error);
        res.status(500).json({ error: 'Failed to delete user', message: error.message });
    }
});

// Get user count by role
router.get('/stats/by-role', async (req, res) => {
    try {
        const usersSnapshot = await db.collection('users').get();

        const stats = {
            total: 0,
            users: 0,
            admins: 0,
        };

        usersSnapshot.forEach(doc => {
            const data = doc.data();
            stats.total++;
            if (data.role === 'admin') {
                stats.admins++;
            } else {
                stats.users++;
            }
        });

        res.json(stats);
    } catch (error) {
        console.error('Error fetching user stats:', error);
        res.status(500).json({ error: 'Failed to fetch user stats', message: error.message });
    }
});

export default router;

import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// Get all orders
router.get('/', async (req, res) => {
    try {
        const { limit = 50, offset = 0, status = '' } = req.query;

        let query = db.collection('orders').orderBy('createdAt', 'desc');

        if (status) {
            query = query.where('status', '==', status);
        }

        const snapshot = await query.limit(parseInt(limit)).offset(parseInt(offset)).get();

        const orders = [];
        for (const doc of snapshot.docs) {
            const data = doc.data();

            // Get user info for each order
            let userName = 'Unknown User';
            if (data.userId) {
                const userDoc = await db.collection('users').doc(data.userId).get();
                if (userDoc.exists) {
                    userName = userDoc.data().name || userDoc.data().email || 'Unknown';
                }
            }

            orders.push({
                id: doc.id,
                ...data,
                userName,
                createdAt: data.createdAt?.toDate?.() || data.createdAt,
            });
        }

        // Get total count
        const countSnapshot = await db.collection('orders').count().get();
        const total = countSnapshot.data().count;

        res.json({
            orders,
            total,
            limit: parseInt(limit),
            offset: parseInt(offset),
        });
    } catch (error) {
        console.error('Error fetching orders:', error);
        res.status(500).json({ error: 'Failed to fetch orders', message: error.message });
    }
});

// Get single order
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('orders').doc(req.params.id).get();

        if (!doc.exists) {
            return res.status(404).json({ error: 'Order not found' });
        }

        const data = doc.data();

        // Get user info
        let user = null;
        if (data.userId) {
            const userDoc = await db.collection('users').doc(data.userId).get();
            if (userDoc.exists) {
                user = { id: userDoc.id, ...userDoc.data() };
            }
        }

        res.json({
            id: doc.id,
            ...data,
            user,
            createdAt: data.createdAt?.toDate?.() || data.createdAt,
        });
    } catch (error) {
        console.error('Error fetching order:', error);
        res.status(500).json({ error: 'Failed to fetch order', message: error.message });
    }
});

// Update order status
router.patch('/:id/status', async (req, res) => {
    try {
        const { status } = req.body;

        if (!['pending', 'completed', 'cancelled'].includes(status)) {
            return res.status(400).json({ error: 'Invalid status' });
        }

        await db.collection('orders').doc(req.params.id).update({
            status,
            updatedAt: new Date(),
        });

        res.json({ message: 'Order status updated successfully', status });
    } catch (error) {
        console.error('Error updating order:', error);
        res.status(500).json({ error: 'Failed to update order', message: error.message });
    }
});

// Delete order
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('orders').doc(req.params.id).delete();
        res.json({ message: 'Order deleted successfully' });
    } catch (error) {
        console.error('Error deleting order:', error);
        res.status(500).json({ error: 'Failed to delete order', message: error.message });
    }
});

// Get order stats
router.get('/stats/summary', async (req, res) => {
    try {
        const ordersSnapshot = await db.collection('orders').get();

        const stats = {
            total: 0,
            pending: 0,
            completed: 0,
            cancelled: 0,
            totalRevenue: 0,
        };

        ordersSnapshot.forEach(doc => {
            const data = doc.data();
            stats.total++;

            if (data.status === 'pending') stats.pending++;
            else if (data.status === 'completed') {
                stats.completed++;
                stats.totalRevenue += data.total || 0;
            }
            else if (data.status === 'cancelled') stats.cancelled++;
        });

        res.json(stats);
    } catch (error) {
        console.error('Error fetching order stats:', error);
        res.status(500).json({ error: 'Failed to fetch order stats', message: error.message });
    }
});

export default router;

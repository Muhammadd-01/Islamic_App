import express from 'express';
import { db } from '../config/firebase.js';

const router = express.Router();

// Get dashboard statistics
router.get('/', async (req, res) => {
    try {
        // Get users count
        const usersSnapshot = await db.collection('users').count().get();
        const totalUsers = usersSnapshot.data().count;

        // Get orders data
        const ordersSnapshot = await db.collection('orders').get();
        let totalOrders = 0;
        let totalRevenue = 0;
        let pendingOrders = 0;

        ordersSnapshot.forEach(doc => {
            const data = doc.data();
            totalOrders++;
            if (data.status === 'completed') {
                totalRevenue += data.total || 0;
            }
            if (data.status === 'pending') {
                pendingOrders++;
            }
        });

        // Get recent users (last 7 days)
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);

        const recentUsersSnapshot = await db.collection('users')
            .where('createdAt', '>=', weekAgo)
            .count()
            .get();
        const newUsersThisWeek = recentUsersSnapshot.data().count;

        // Get recent orders (last 7 days)  
        const recentOrdersSnapshot = await db.collection('orders')
            .where('createdAt', '>=', weekAgo)
            .count()
            .get();
        const ordersThisWeek = recentOrdersSnapshot.data().count;

        res.json({
            totalUsers,
            totalOrders,
            totalRevenue,
            pendingOrders,
            newUsersThisWeek,
            ordersThisWeek,
            lastUpdated: new Date().toISOString(),
        });
    } catch (error) {
        console.error('Error fetching stats:', error);
        res.status(500).json({ error: 'Failed to fetch stats', message: error.message });
    }
});

// Get chart data - orders over time
router.get('/orders-chart', async (req, res) => {
    try {
        const { days = 7 } = req.query;
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - parseInt(days));

        const ordersSnapshot = await db.collection('orders')
            .where('createdAt', '>=', startDate)
            .orderBy('createdAt', 'asc')
            .get();

        // Group by date
        const chartData = {};
        for (let i = 0; i < days; i++) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];
            chartData[dateStr] = { date: dateStr, orders: 0, revenue: 0 };
        }

        ordersSnapshot.forEach(doc => {
            const data = doc.data();
            const date = data.createdAt?.toDate?.() || new Date(data.createdAt);
            const dateStr = date.toISOString().split('T')[0];

            if (chartData[dateStr]) {
                chartData[dateStr].orders++;
                if (data.status === 'completed') {
                    chartData[dateStr].revenue += data.total || 0;
                }
            }
        });

        res.json(Object.values(chartData).reverse());
    } catch (error) {
        console.error('Error fetching chart data:', error);
        res.status(500).json({ error: 'Failed to fetch chart data', message: error.message });
    }
});

export default router;

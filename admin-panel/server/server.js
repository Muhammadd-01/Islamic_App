import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Import routes
import usersRoutes from './routes/users.js';
import ordersRoutes from './routes/orders.js';
import statsRoutes from './routes/stats.js';

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
    origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:5173', 'http://localhost:3000'],
    credentials: true,
}));
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        message: 'Islamic App Admin API is running'
    });
});

// API Routes
app.use('/api/users', usersRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/stats', statsRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server Error:', err);
    res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not Found' });
});

// Start server
app.listen(PORT, () => {
    console.log(`
  ╔════════════════════════════════════════════╗
  ║    Islamic App Admin Panel - Server        ║
  ╠════════════════════════════════════════════╣
  ║  🚀 Server running on port ${PORT}            ║
  ║  📚 API: http://localhost:${PORT}/api         ║
  ║  🏥 Health: http://localhost:${PORT}/api/health║
  ╚════════════════════════════════════════════╝
  `);
});


import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Import routes
import usersRoutes from './routes/users.js';
import ordersRoutes from './routes/orders.js';
import statsRoutes from './routes/stats.js';
import booksRoutes from './routes/books.js';
import questionsRoutes from './routes/questions.js';
import inventionsRoutes from './routes/inventions.js';
import scientistsRoutes from './routes/scientists.js';
import namesRoutes from './routes/names.js';
import duasRoutes from './routes/duas.js';
import inspirationRoutes from './routes/inspiration.js';
import newsRoutes from './routes/news.js';
import politicsRoutes from './routes/politics.js';
import scholarsRoutes from './routes/scholars.js';
import coursesRoutes from './routes/courses.js';
import historyRoutes from './routes/history.js';
import religionsRoutes from './routes/religions.js';
import hadithsRoutes from './routes/hadiths.js';
import quranRoutes from './routes/quran.js';
import dailyInspirationsRoutes from './routes/daily_inspirations.js';
import tasbeehRoutes from './routes/tasbeeh.js';
import azkarRoutes from './routes/azkar.js';
import regionsRoutes from './routes/regions.js';
import donationsRoutes from './routes/donations.js';
import bookingsRoutes from './routes/bookings.js';
import settingsRoutes from './routes/settings.js';
import whatsappService from './utils/whatsappService.js';
import { seedSuperAdmin } from './utils/seed_admin.js';

seedSuperAdmin();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
    origin: function (origin, callback) {
        const allowedOrigins = process.env.CORS_ORIGINS?.split(',') || ['http://localhost:5173', 'http://localhost:3000'];
        // Allow requests with no origin (like mobile apps or curl requests)
        if (!origin) return callback(null, true);
        if (allowedOrigins.indexOf(origin) !== -1 || origin.startsWith('http://localhost:')) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
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
app.use('/api/books', booksRoutes);
app.use('/api/questions', questionsRoutes);
app.use('/api/inventions', inventionsRoutes);
app.use('/api/scientists', scientistsRoutes);
app.use('/api/names', namesRoutes);
app.use('/api/duas', duasRoutes);
app.use('/api/inspiration', inspirationRoutes);
app.use('/api/news', newsRoutes);
app.use('/api/politics', politicsRoutes);
app.use('/api/scholars', scholarsRoutes);
app.use('/api/courses', coursesRoutes);
app.use('/api/history', historyRoutes);
app.use('/api/religions', religionsRoutes);
app.use('/api/hadiths', hadithsRoutes);
app.use('/api/quran', quranRoutes);
app.use('/api/daily-inspirations', dailyInspirationsRoutes);
app.use('/api/tasbeeh', tasbeehRoutes);
app.use('/api/azkar', azkarRoutes);
app.use('/api/regions', regionsRoutes);
app.use('/api/donations', donationsRoutes);
app.use('/api/bookings', bookingsRoutes);
app.use('/api/settings', settingsRoutes);

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
app.listen(PORT, async () => {
    console.log(`
  ╔════════════════════════════════════════════╗
  ║    Islamic App Admin Panel - Server        ║
  ╠════════════════════════════════════════════╣
  ║  🚀 Server running on port ${PORT}            ║
  ║  📚 API: http://localhost:${PORT}/api         ║
  ║  🏥 Health: http://localhost:${PORT}/api/health║
  ╚════════════════════════════════════════════╝
  `);

    // Initialize System WhatsApp
    try {
        await whatsappService.initialize();
    } catch (err) {
        console.error('Initial WhatsApp startup failed:', err);
    }
});

import express from 'express';
import { db } from '../config/firebase.js';
import { sendPushNotification } from '../utils/onesignal.js';

const router = express.Router();

// Get all questions
router.get('/', async (req, res) => {
    try {
        const { status = '' } = req.query;

        let query = db.collection('questions').orderBy('createdAt', 'desc');

        if (status) {
            query = query.where('status', '==', status);
        }

        const snapshot = await query.get();

        const questions = [];
        for (const doc of snapshot.docs) {
            const data = doc.data();

            // Get user info
            let userName = 'Anonymous';
            if (data.userId) {
                const userDoc = await db.collection('users').doc(data.userId).get();
                if (userDoc.exists) {
                    userName = userDoc.data().name || userDoc.data().email || 'Anonymous';
                }
            }

            questions.push({
                id: doc.id,
                ...data,
                userName,
                createdAt: data.createdAt?.toDate?.() || data.createdAt,
                answeredAt: data.answeredAt?.toDate?.() || data.answeredAt,
            });
        }

        res.json({ questions, total: questions.length });
    } catch (error) {
        console.error('Error fetching questions:', error);
        res.status(500).json({ error: 'Failed to fetch questions', message: error.message });
    }
});

// Get single question
router.get('/:id', async (req, res) => {
    try {
        const doc = await db.collection('questions').doc(req.params.id).get();

        if (!doc.exists) {
            return res.status(404).json({ error: 'Question not found' });
        }

        res.json({ id: doc.id, ...doc.data() });
    } catch (error) {
        console.error('Error fetching question:', error);
        res.status(500).json({ error: 'Failed to fetch question', message: error.message });
    }
});

// Answer a question
router.post('/:id/answer', async (req, res) => {
    try {
        const { answer } = req.body;

        if (!answer || answer.trim() === '') {
            return res.status(400).json({ error: 'Answer is required' });
        }

        const questionRef = db.collection('questions').doc(req.params.id);
        const questionDoc = await questionRef.get();

        if (!questionDoc.exists) {
            return res.status(404).json({ error: 'Question not found' });
        }

        const questionData = questionDoc.data();

        // Update question with answer
        await questionRef.update({
            answer,
            status: 'answered',
            answeredAt: new Date(),
        });

        // Create notification for the user who asked
        if (questionData.userId) {
            const notificationTitle = 'Your Question Was Answered!';
            const notificationMessage = `Your question "${questionData.question.substring(0, 50)}..." has been answered.`;

            // Firestore notification (for in-app history)
            await db.collection('notifications').add({
                userId: questionData.userId,
                type: 'question_answered',
                title: notificationTitle,
                message: notificationMessage,
                questionId: req.params.id,
                read: false,
                createdAt: new Date(),
            });

            // OneSignal push notification
            sendPushNotification({
                title: notificationTitle,
                message: notificationMessage,
                userIds: [questionData.userId],
                data: {
                    type: 'question_answered',
                    questionId: req.params.id
                }
            });
        }

        res.json({ message: 'Question answered successfully' });
    } catch (error) {
        console.error('Error answering question:', error);
        res.status(500).json({ error: 'Failed to answer question', message: error.message });
    }
});

// Delete question
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('questions').doc(req.params.id).delete();
        res.json({ message: 'Question deleted successfully' });
    } catch (error) {
        console.error('Error deleting question:', error);
        res.status(500).json({ error: 'Failed to delete question', message: error.message });
    }
});

// Get question stats
router.get('/stats/summary', async (req, res) => {
    try {
        const snapshot = await db.collection('questions').get();

        const stats = {
            total: 0,
            pending: 0,
            answered: 0,
        };

        snapshot.forEach(doc => {
            const data = doc.data();
            stats.total++;
            if (data.status === 'answered') stats.answered++;
            else stats.pending++;
        });

        res.json(stats);
    } catch (error) {
        console.error('Error fetching question stats:', error);
        res.status(500).json({ error: 'Failed to fetch stats', message: error.message });
    }
});

export default router;

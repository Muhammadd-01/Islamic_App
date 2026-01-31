import express from 'express';
import { db } from '../config/firebase.js';
import { sendPushNotification } from '../utils/onesignal.js';

const router = express.Router();

// GET all enrollments
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('course_enrollments').get();
        const enrollments = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        res.json(enrollments);
    } catch (error) {
        console.error('Error fetching enrollments:', error);
        res.status(500).json({ error: 'Failed to fetch enrollments' });
    }
});

// PATCH update enrollment status
router.patch('/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        if (!['pending', 'approved', 'rejected'].includes(status)) {
            return res.status(400).json({ error: 'Invalid status' });
        }

        await db.collection('course_enrollments').doc(req.params.id).update({
            status,
            updatedAt: new Date().toISOString()
        });

        // Trigger Notification
        const enrollmentDoc = await db.collection('course_enrollments').doc(req.params.id).get();
        const enrollment = enrollmentDoc.data();
        if (enrollment && enrollment.userId) {
            const title = 'Enrollment Status Update';
            const message = `Your enrollment for ${enrollment.courseTitle} has been ${status}.`;

            // 1. Save to Firestore for the App's notification screen
            await db.collection('notifications').add({
                userId: enrollment.userId,
                title: title,
                message: message,
                type: 'booking', // 'booking' matches the icon in NotificationsScreen
                read: false,
                createdAt: new Date(),
                courseId: enrollment.courseId,
                enrollmentId: req.params.id
            });

            // 2. Send Push Notification via OneSignal
            console.log(`Attempting to send OneSignal push to External User ID: ${enrollment.userId}`);
            sendPushNotification({
                title: title,
                message: message,
                userIds: [enrollment.userId],
                data: {
                    type: 'enrollment_status',
                    courseId: enrollment.courseId,
                    status: status
                }
            });
        }

        res.json({ message: 'Enrollment status updated successfully' });
    } catch (error) {
        console.error('Error updating enrollment status:', error);
        res.status(500).json({ error: 'Failed to update enrollment status' });
    }
});

// DELETE enrollment
router.delete('/:id', async (req, res) => {
    try {
        await db.collection('course_enrollments').doc(req.params.id).delete();
        res.json({ message: 'Enrollment deleted successfully' });
    } catch (error) {
        console.error('Error deleting enrollment:', error);
        res.status(500).json({ error: 'Failed to delete enrollment' });
    }
});

export default router;

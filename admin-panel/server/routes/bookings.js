import express from 'express';
import admin from 'firebase-admin';

const router = express.Router();
const db = admin.firestore();

// GET all bookings (for admin global view)
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('bookings').orderBy('createdAt', 'desc').get();
        const bookings = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json({ success: true, bookings });
    } catch (error) {
        console.error('Error fetching bookings:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// GET bookings for a specific scholar
router.get('/scholar/:scholarId', async (req, res) => {
    try {
        const snapshot = await db.collection('bookings')
            .where('scholarId', '==', req.params.scholarId)
            // .orderBy('createdAt', 'desc') // Requires composite index if where is used
            .get();
        const bookings = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

        // Manual sort to avoid needing immediate composite index
        bookings.sort((a, b) => (b.createdAt?.seconds || 0) - (a.createdAt?.seconds || 0));

        res.json({ success: true, bookings });
    } catch (error) {
        console.error('Error fetching scholar bookings:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST create a booking
router.post('/', async (req, res) => {
    try {
        const {
            scholarId,
            scholarName,
            userId,
            userName,
            userEmail,
            userPhone,
            dateTime,
            fee
        } = req.body;

        if (!scholarId || !userId) {
            return res.status(400).json({ success: false, message: 'Missing required fields' });
        }

        // 1. Create the booking record
        const bookingData = {
            scholarId,
            scholarName: scholarName || 'Scholar',
            userId,
            userName: userName || 'Anonymous',
            userEmail: userEmail || 'N/A',
            userPhone: userPhone || 'N/A',
            dateTime,
            fee: parseFloat(fee) || 0,
            status: 'Confirmed',
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        };

        const bookingRef = await db.collection('bookings').add(bookingData);

        // 2. Mark the scholar as Booked
        await db.collection('scholars').doc(scholarId).update({
            isBooked: true
        });

        // 3. Simulate Backend Notification (e.g., WhatsApp Notification Log)
        console.log(`\n--- [AUTOMATED CONSULTATION ALERT] ---`);
        console.log(`To Scholar: ${scholarName} (ID: ${scholarId})`);
        console.log(`Booking for: ${dateTime}`);
        console.log(`\nUSER DETAILS FOR CONTACT:`);
        console.log(`Name:  ${userName}`);
        console.log(`Email: ${userEmail}`);
        console.log(`Phone: ${userPhone}`);
        console.log(`---------------------------------------\n`);

        res.json({
            success: true,
            message: 'Booking completed successfully and scholar notified.',
            bookingId: bookingRef.id
        });
    } catch (error) {
        console.error('Error creating booking:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

export default router;

import { db, admin } from '../config/firebase.js';

export const seedSuperAdmin = async () => {
    try {
        const email = 'superadmin@islamicapp.com';
        const password = 'adminpassword123'; // In production, use env var
        const displayName = 'Super Admin';

        let userRecord;

        try {
            userRecord = await admin.auth().getUserByEmail(email);
            console.log('Super Admin exists:', userRecord.uid);
        } catch (error) {
            if (error.code === 'auth/user-not-found') {
                userRecord = await admin.auth().createUser({
                    email,
                    password,
                    displayName,
                });
                console.log('Super Admin created:', userRecord.uid);
            } else {
                throw error;
            }
        }

        // Ensure Firestore profile exists and has role: super_admin
        const userDocRef = db.collection('users').doc(userRecord.uid);
        const doc = await userDocRef.get();

        if (!doc.exists || doc.data().role !== 'super_admin') {
            await userDocRef.set({
                uid: userRecord.uid,
                email,
                name: displayName,
                role: 'super_admin',
                createdAt: new Date(),
                updatedAt: new Date(),
            }, { merge: true });
            console.log('Super Admin Firestore profile updated.');
        }

    } catch (error) {
        console.error('Error seeding super admin:', error);
    }
};

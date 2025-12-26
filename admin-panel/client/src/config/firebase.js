import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
    apiKey: 'AIzaSyCt1VzmHVTXwCkIq3B1GnMIC6JKlNbdKXo',
    authDomain: 'islamic-app-backend.firebaseapp.com',
    projectId: 'islamic-app-backend',
    storageBucket: 'islamic-app-backend.firebasestorage.app',
    messagingSenderId: '276908933332',
    appId: '1:276908933332:web:f01360a14c8c5eb1f2bb41',
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);

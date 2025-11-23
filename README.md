# Islamic App - Your Complete Islamic Companion

A comprehensive Flutter application designed to help Muslims in their daily spiritual journey with prayer times, Quran reading, Hadith collections, Islamic calendar, and much more.

## 📱 Features

### 🕌 Core Features
- **Prayer Times**: Accurate prayer times based on your location with Aladhan API integration
- **Quran Reader**: Complete Quran with translations and audio recitation
- **Hadith Collections**: Authentic Hadith from various collections
- **Islamic Calendar**: Hijri calendar with important Islamic dates
- **Qibla Finder**: Compass to find the direction of Kaaba
- **Tasbeeh Counter**: Digital counter for Dhikr and Tasbih
- **99 Names of Allah**: Beautiful display of Allah's names with meanings
- **Dua Collections**: Comprehensive collection of daily supplications

### 👤 User Features
- **Authentication**: Email/Password, Google Sign-In, Facebook Sign-In
- **Forgot Password**: Email-based password reset with Firebase Auth
- **User Profiles**: Customizable profiles with bio, location, and profile pictures
- **Image Storage**: Profile images stored in Supabase Storage
- **Location Services**: Auto-detect location for prayer times and nearby mosques
- **Bookmarks**: Save and organize Quran verses, Hadiths, Duas, Q&A, and Books
  - Real-time sync with Firestore
  - Filter by type (Quran, Hadith, Dua, Q&A, Books)
  - Quick access to bookmarked content
  - Remove bookmarks with confirmation

### 📚 Educational Features
- **Islamic Courses**: Learn about Islam through structured courses
- **Q&A Section**: Ask and answer Islamic questions
- **Study Religions**: Comparative study of world religions
- **Debate Panel**: Theological discussions and debates
- **Scholars**: Learn from renowned Islamic scholars

### 🎨 UI/UX Features
- **Modern Design**: Beautiful gradients and glassmorphism effects
- **Dark Mode**: Full dark mode support
- **Smooth Animations**: Fade, slide, and scale animations throughout
- **Multilingual**: Support for multiple languages
- **Responsive**: Works on phones, tablets, and web

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account
- Supabase account (for image storage)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/islamic-app.git
   cd islamic-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Follow the detailed guide in `firebase_setup_guide.md`
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure Firebase Authentication, Firestore, and Storage

4. **Supabase Setup**
   - Follow the detailed guide in `SUPABASE_SETUP.md`
   - Create a storage bucket for profile images
   - Add Supabase URL and anon key to your app

5. **Initialize Supabase in main.dart**
   ```dart
   await SupabaseService.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Usage

### Authentication
1. **Sign Up**: Create an account with name, email, and password
2. **Login**: Sign in with email/password, Google, or Facebook
3. **Forgot Password**: Reset password via email link
4. **Change Password**: Access from profile screen
5. **Profile**: Edit your profile, add bio, location, and profile picture

### Bookmarks
- **Add Bookmark**: Tap bookmark icon on any content (Quran, Hadith, Dua, Q&A, Books)
- **View Bookmarks**: Access from profile or navigation menu
- **Filter**: Filter bookmarks by type
- **Remove**: Swipe or tap delete icon to remove bookmarks
- **Sync**: All bookmarks sync in real-time across devices via Firestore

### Prayer Times
- Automatic location detection for accurate prayer times
- Notifications for upcoming prayers
- Hijri calendar integration

### Quran & Hadith
- Read Quran with translations
- Listen to audio recitations
- Browse Hadith collections
- Bookmark favorite verses and Hadiths

### Tools
- **Tasbeeh Counter**: Track your Dhikr
- **Qibla Finder**: Find direction to Mecca
- **99 Names**: Learn Allah's beautiful names
- **Dua**: Access daily supplications

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants and colors
│   ├── providers/      # Global providers
│   └── theme/          # Theme configuration
├── data/
│   ├── models/         # Data models
│   ├── repositories/   # Repository implementations
│   └── services/       # API and external services
├── domain/
│   ├── entities/       # Domain entities
│   └── repositories/   # Repository interfaces
├── presentation/
│   ├── auth/           # Authentication screens
│   ├── home/           # Home screen
│   ├── prayer/         # Prayer times
│   ├── quran/          # Quran reader
│   ├── hadith/         # Hadith collections
│   ├── profile/        # User profile
│   └── widgets/        # Reusable widgets
└── main.dart           # App entry point
```

## 🔧 Technologies Used

- **Flutter**: Cross-platform framework
- **Riverpod**: State management
- **Firebase**: Authentication, Firestore, FCM
- **Supabase**: Image storage
- **Aladhan API**: Prayer times
- **AlQuran Cloud API**: Quran data
- **Geolocator**: Location services
- **Image Picker**: Profile image selection

## 📝 Firebase Schema

```
users/
  {uid}/
    name: string
    email: string
    phone: string (optional)
    bio: string
    location: string
    imageUrl: string (Supabase URL)
    preferences: map
    bookmarks: array
    createdAt: timestamp
    
    bookmarks/ (subcollection)
      {bookmarkId}/
        id: string
        type: string (quran/hadith/dua/qa/book)
        title: string
        subtitle: string
        content: string
        route: string
        timestamp: string (ISO 8601)
        sourceUrl: string (optional)
        metadata: map (optional)
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Aladhan API for prayer times
- AlQuran Cloud for Quran data
- Firebase for backend services
- Supabase for image storage
- All contributors and testers

## 📧 Contact

For questions or support, please open an issue on GitHub or contact us at support@islamicapp.com

---

**Made with ❤️ for the Muslim Ummah**

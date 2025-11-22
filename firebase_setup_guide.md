# Firebase Setup Guide for Islamic App

Follow these steps to connect your Flutter app to Firebase for Authentication and other backend services.

## Prerequisites
- A Google Account
- [Node.js](https://nodejs.org/) installed (for Firebase CLI)
- Flutter SDK installed

## Step 1: Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **"Add project"**.
3. Enter a project name (e.g., `islamic-app-backend`).
4. Disable Google Analytics for now (optional) and click **"Create project"**.

## Step 2: Install Firebase CLI & FlutterFire
1. Open your terminal.
2. Install Firebase CLI globally:
   ```bash
   npm install -g firebase-tools
   ```
3. Log in to Firebase:
   ```bash
   firebase login
   ```
4. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

## Step 3: Configure the App
1. In your terminal, navigate to the project root:
   ```bash
   cd /Users/muhammadaffan/Coding/Islamic-App
   ```
2. Run the configuration command:
   ```bash
   flutterfire configure
   ```
3. Select your newly created project from the list.
4. Select the platforms you want to support (Android, iOS).
5. The CLI will automatically:
   - Register your Android and iOS apps in the Firebase Console.
   - Download and place `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) in the correct folders.
   - Update your `lib/firebase_options.dart` file.

## Step 4: Enable Authentication
1. Go to your project in the Firebase Console.
2. Navigate to **Build > Authentication**.
3. Click **"Get started"**.
4. Select **"Email/Password"** as a Sign-in method and enable it.
5. Click **"Save"**.

## Step 5: Verify Integration
1. In `lib/main.dart`, uncomment the Firebase initialization lines:
   ```dart
   // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
2. Run the app:
   ```bash
   flutter run
   ```
3. Try signing up with a new email/password.

## Troubleshooting
- **Android Build Fails**: Ensure your `android/build.gradle` and `android/app/build.gradle` have the correct classpath and plugin dependencies (FlutterFire usually handles this, but double-check documentation if issues arise).
- **iOS Build Fails**: Ensure you have run `pod install` in the `ios` directory.

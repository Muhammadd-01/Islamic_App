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

## Step 6: Enable Firestore Database
1. In Firebase Console, go to **Build > Firestore Database**.
2. Click **"Create database"**.
3. Select **"Start in test mode"** (for development).
4. Choose a location and click **"Enable"**.

## Step 7: Enable Firebase Storage
1. In Firebase Console, go to **Build > Storage**.
2. Click **"Get started"**.
3. Select **"Start in test mode"** (for development).
4. Click **"Done"**.

## Step 8: Enable Google Sign-In
1. In Firebase Console, go to **Build > Authentication > Sign-in method**.
2. Click **"Google"** and toggle **"Enable"**.
3. Enter a support email and click **"Save"**.

### Android Setup for Google Sign-In
1. Get your SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy the SHA-1 from the debug keystore.
3. In Firebase Console, go to **Project Settings > Your apps > Android app**.
4. Click **"Add fingerprint"** and paste the SHA-1.

### iOS Setup for Google Sign-In
1. In Firebase Console, go to **Project Settings > Your apps > iOS app**.
2. Download the updated `GoogleService-Info.plist`.
3. Replace the existing file in `ios/Runner/`.
4. Open `ios/Runner/Info.plist` and add:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```
   (Replace `YOUR_REVERSED_CLIENT_ID` with the value from `GoogleService-Info.plist`)

## Step 9: Enable Facebook Sign-In
1. Create a Facebook App at [developers.facebook.com](https://developers.facebook.com/).
2. Get your **App ID** and **App Secret**.
3. In Firebase Console, go to **Build > Authentication > Sign-in method**.
4. Click **"Facebook"** and toggle **"Enable"**.
5. Enter your App ID and App Secret, then click **"Save"**.
6. Copy the OAuth redirect URI from Firebase and add it to your Facebook App settings.

### Android Setup for Facebook
1. Open `android/app/src/main/res/values/strings.xml` and add:
   ```xml
   <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
   <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
   ```
2. Open `android/app/src/main/AndroidManifest.xml` and add inside `<application>`:
   ```xml
   <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
   ```

### iOS Setup for Facebook
1. Open `ios/Runner/Info.plist` and add:
   ```xml
   <key>FacebookAppID</key>
   <string>YOUR_FACEBOOK_APP_ID</string>
   <key>FacebookDisplayName</key>
   <string>Islamic App</string>
   ```

## Step 10: Monitor Users in Firebase Console
1. Go to **Build > Authentication > Users** to see all registered users.
2. You can view:
   - User UID
   - Email
   - Sign-in provider (Email, Google, Facebook)
   - Creation date
   - Last sign-in
3. Go to **Build > Firestore Database > Data** to see user profiles and other data.
4. Go to **Build > Storage > Files** to see uploaded profile images.

## Testing
1. Run your app: `flutter run`
2. Try signing up with email/password.
3. Try signing in with Google.
4. Try signing in with Facebook.
5. Check Firebase Console to see the new users appear in real-time!

## Step 11: Supabase Integration for Images

### Why Supabase?
Firebase Storage is a paid service. To save costs, we use **Supabase Storage** for hosting profile images. The public URLs from Supabase are stored in Firebase Firestore.

### Setup Process
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Create a storage bucket named `profile-images`
3. Set the bucket to **public** for read access
4. Configure Row Level Security (RLS) policies for upload/delete

### Detailed Instructions
See `SUPABASE_SETUP.md` for complete step-by-step instructions on:
- Creating Supabase project
- Configuring storage bucket
- Setting up security policies
- Integrating with Flutter app
- Upload/delete/display images

### How It Works
1. User selects profile image
2. Image uploads to Supabase Storage
3. Supabase returns public URL
4. URL is saved in Firestore under `users/{uid}/imageUrl`
5. App displays image using the Firestore URL

### Firestore Schema with Supabase
```
users/
  {uid}/
    name: string
    email: string
    phone: string
    bio: string
    location: string
    imageUrl: string  ← Supabase public URL
    preferences: map
    bookmarks: array
    createdAt: timestamp
```

### Code Example
```dart
// Initialize Supabase in main.dart
await SupabaseService.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);

// Upload image
final supabaseService = SupabaseService();
final imageUrl = await supabaseService.uploadProfileImage(uid, imageFile);

// Save URL to Firestore
await userRepository.updateUserProfile(imageUrl: imageUrl);
```

For complete implementation details, refer to `SUPABASE_SETUP.md`.

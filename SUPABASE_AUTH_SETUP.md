# Supabase Authentication Setup Guide

This guide covers the manual steps required to enable **Google** and **Facebook** authentication in your Supabase project and link it to your Flutter app.

---

## 1. Google Authentication Setup

### A. Google Cloud Console
1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or select an existing one.
3. Search for **"Google Auth platform"** (this is the new name for the OAuth consent screen).
4. On the left sidebar, go to **Audience**:
   - Here you will find the **User Type**.
   - Select **External** (so anyone with a Google account can log in).
   - *Note: If you only see "External" or "Internal" as a fixed label, it's already set.*
5. Go to **Branding** on the left sidebar:
   - Fill in **App name** (e.g., DeenSphere).
   - Select your **User support email**.
   - Scroll down to **Developer contact information** and enter your email.
   - Click **Save**.
6. Go to **Data Access** (optional):
   - You can see the requested "Scopes" here. For basic login, you don't need to add anything extra.
7. Finally, go to **"Credentials"** (in the main sidebar) -> **"Create Credentials"** -> **"OAuth client ID"**.
8. Select **Web application** (Supabase uses Web flow for OAuth internally).
9. Under **Authorized redirect URIs**, add your Supabase Callback URL:
   - Find this in **Supabase Dashboard → Authentication → URL Configuration**.
   - It usually looks like: `https://[YOUR-PROJECT-ID].supabase.co/auth/v1/callback`
10. Copy the **Client ID** and **Client Secret**.

### B. Supabase Dashboard
1. Go to **Authentication → Providers → Google**.
2. Toggle **Enable Google ID Provider**.
3. Paste the **Client ID** and **Client Secret** from Google Cloud.
4. Click **Save**.

---

## 2. Facebook Authentication Setup

### A. Meta for Developers
1. Go to [Meta for Developers](https://developers.facebook.com/).
2. Create a new App (Select **"Allow people to log in with their Facebook account"**).
3. In the App Dashboard, go to **"Use cases"** and add **"Authentication and account creation"** (Facebook Login).
4. Go to **"Facebook Login" → "Settings"**.
5. Under **Valid OAuth Redirect URIs**, paste your Supabase Callback URL:
   - `https://[YOUR-PROJECT-ID].supabase.co/auth/v1/callback`
6. Go to **"App Settings" → "Basic"**.
7. Copy the **App ID** and **App Secret**.

### B. Supabase Dashboard
1. Go to **Authentication → Providers → Facebook**.
2. Toggle **Enable Facebook ID Provider**.
3. Paste the **App ID** and **App Secret**.
4. Click **Save**.

---

## 3. Flutter App Configuration (Deep Linking)

To return the user back to the app after the browser login, you must configure deep linking.

### A. Define Redirect URL in Supabase
1. Go to **Authentication → URL Configuration**.
2. Update the **Site URL** to:
   - URL: `https://deensphere.com`
   - *(Note: This replaces the default localhost:3000)*
3. Add your app's custom scheme to **Redirect URLs**:
   - URL: `com.islamicapp.islamic-app://login-callback`

### B. Android Setup
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.islamicapp.islamic-app" android:host="login-callback" />
</intent-filter>
```

### C. iOS Setup
Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.islamicapp.islamic-app</string>
        </array>
    </dict>
</array>
```

---

## 4. Usage in Code

The app is already configured to use these providers. When you call:
```dart
ref.read(authRepositoryProvider).signInWithGoogle();
```
It will open the browser for authentication and use the deep link to return to the app.

# Admin Panel Server Setup

## Firebase Credentials Setup

Since `serviceAccountKey.json` and `.env` are gitignored for security, you need to set them up manually after cloning.

### Option 1: Using Service Account JSON File (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project → Project Settings → Service Accounts
3. Click "Generate new private key"
4. Save the file as `admin-panel/server/config/serviceAccountKey.json`

### Option 2: Using Environment Variables

Create `admin-panel/server/.env` with:

```env
PORT=5000
FIREBASE_PROJECT_ID="your-project-id"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

## Running the Server

```bash
cd admin-panel
npm install
npm run dev
```

## Common Issues

### 16 UNAUTHENTICATED Error
This means your Firebase credentials are missing or invalid. Make sure:
1. `serviceAccountKey.json` exists in `config/` folder
2. OR `.env` file has correct FIREBASE_* variables
3. Restart the server after adding credentials

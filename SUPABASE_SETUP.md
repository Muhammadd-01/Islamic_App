# Supabase Setup Guide for Islamic App

This guide will walk you through setting up Supabase Storage for profile image management in the Islamic App.

## Why Supabase?

Firebase Storage is a paid service, so we use **Supabase Storage** for hosting profile images. The public URLs from Supabase are then stored in Firebase Firestore for easy retrieval.

## Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click **"Start your project"** or **"New Project"**
3. Sign in with GitHub (recommended) or create an account
4. Create a new organization if you don't have one
5. Click **"New Project"**
6. Fill in project details:
   - **Name**: `islamic-app` (or your preferred name)
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose closest to your users
7. Click **"Create new project"**
8. Wait for the project to be provisioned (~2 minutes)

## Step 2: Get Your Supabase Credentials

1. Once your project is ready, go to **Settings > API**
2. Copy the following:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **anon/public key**: Long string starting with `eyJ...`

## Step 3: Create Storage Bucket

1. In your Supabase dashboard, go to **Storage** (left sidebar)
2. Click **"New bucket"**
3. Enter bucket details:
   - **Name**: `profile-images`
   - **Public bucket**: Toggle **ON** (so images are publicly accessible)
4. Click **"Create bucket"**

## Step 4: Configure Bucket Policies

To allow users to upload and delete their own images:

1. Click on the `profile-images` bucket
2. Go to **Policies** tab
3. Click **"New Policy"**

### Policy 1: Allow Upload
```sql
CREATE POLICY "Allow authenticated users to upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'profile-images');
```

### Policy 2: Allow Update/Delete
```sql
CREATE POLICY "Allow users to update their own images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'profile-images');

CREATE POLICY "Allow users to delete their own images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'profile-images');
```

### Policy 3: Allow Public Read
```sql
CREATE POLICY "Allow public read access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-images');
```

## Step 5: Initialize Supabase in Flutter

1. Open `lib/main.dart`
2. Add Supabase initialization **before** `runApp()`:

```dart
import 'package:islamic_app/data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Supabase
  await SupabaseService.initialize(
    url: 'YOUR_SUPABASE_PROJECT_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

3. Replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_ANON_KEY` with your actual credentials from Step 2.

## Step 6: How It Works

### Upload Flow
1. User picks an image using `image_picker`
2. Image is uploaded to Supabase Storage bucket `profile-images`
3. Supabase returns a public URL (e.g., `https://your-project.supabase.co/storage/v1/object/public/profile-images/profiles/profile_uid.jpg`)
4. This URL is saved in Firebase Firestore under `users/{uid}/imageUrl`
5. App displays the image using the URL from Firestore

### Update Flow
1. User picks a new image
2. Old image is deleted from Supabase (using the stored URL)
3. New image is uploaded to Supabase
4. New URL is saved in Firestore

### Delete Flow
1. Extract file path from the stored URL
2. Call Supabase Storage delete API
3. Remove URL from Firestore

## Step 7: Code Examples

### Upload Image
```dart
final supabaseService = SupabaseService();
final user = FirebaseAuth.instance.currentUser;

if (user != null && imageFile != null) {
  final imageUrl = await supabaseService.uploadProfileImage(
    user.uid,
    imageFile,
  );
  
  // Save URL to Firestore
  await userRepository.updateUserProfile(imageUrl: imageUrl);
}
```

### Update Image
```dart
final supabaseService = SupabaseService();
final user = FirebaseAuth.instance.currentUser;

if (user != null && newImageFile != null) {
  final newImageUrl = await supabaseService.updateProfileImage(
    user.uid,
    newImageFile,
    oldImageUrl, // Will delete old image
  );
  
  // Save new URL to Firestore
  await userRepository.updateUserProfile(imageUrl: newImageUrl);
}
```

### Delete Image
```dart
final supabaseService = SupabaseService();

await supabaseService.deleteProfileImage(imageUrl);

// Remove URL from Firestore
await userRepository.updateUserProfile(imageUrl: '');
```

### Display Image
```dart
CircleAvatar(
  radius: 60,
  backgroundImage: imageUrl != null && imageUrl.isNotEmpty
      ? NetworkImage(imageUrl)
      : null,
  child: imageUrl == null || imageUrl.isEmpty
      ? const Icon(Icons.person, size: 60)
      : null,
)
```

## Step 8: Error Handling

The `SupabaseService` includes error handling for:
- Upload failures
- Network errors
- Invalid file paths
- Permission issues

Example:
```dart
try {
  final imageUrl = await supabaseService.uploadProfileImage(uid, file);
  // Success
} catch (e) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to upload image: $e')),
  );
}
```

## Step 9: Testing

1. **Upload Test**:
   - Open Edit Profile screen
   - Tap on profile image
   - Select an image from gallery
   - Tap save
   - Check Supabase dashboard → Storage → profile-images
   - Verify image appears in bucket

2. **Firestore Verification**:
   - Go to Firebase Console → Firestore
   - Find your user document
   - Verify `imageUrl` field contains Supabase URL

3. **Display Test**:
   - Navigate to Profile screen
   - Verify image displays correctly
   - Check Home screen greeting (should also show image if implemented)

## Step 10: Production Considerations

### Security
- ✅ Use Row Level Security (RLS) policies
- ✅ Validate file types and sizes on client
- ✅ Consider server-side validation
- ✅ Rate limit uploads

### Performance
- ✅ Compress images before upload
- ✅ Use appropriate image formats (JPEG for photos, PNG for graphics)
- ✅ Implement caching
- ✅ Show upload progress

### Costs
- Supabase Free Tier: 1GB storage, 2GB bandwidth
- Monitor usage in Supabase dashboard
- Upgrade plan if needed

## Troubleshooting

### Image Not Uploading
- Check internet connection
- Verify Supabase credentials in `main.dart`
- Check bucket policies are correctly set
- Ensure bucket is public

### Image Not Displaying
- Verify URL is saved in Firestore
- Check URL format (should start with `https://`)
- Test URL in browser
- Check network permissions in app

### Permission Denied
- Verify RLS policies are set correctly
- Check user is authenticated
- Ensure bucket is public for read access

## Additional Resources

- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/introduction)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

**Need Help?**
- Supabase Discord: [discord.supabase.com](https://discord.supabase.com)
- GitHub Issues: Open an issue in the project repository

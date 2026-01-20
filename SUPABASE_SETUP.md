# Supabase Storage Setup - Complete Guide

This guide covers creating all required buckets for the Islamic App.

## Step 1: Create Storage Buckets

Go to **Supabase Dashboard → Storage → New bucket**

Create these buckets (all with **Public bucket: ON**):

| Bucket Name | Purpose |
|-------------|---------|
| `profile-images` | User profile photos |
| `religion-images` | Religion/Belief content images |
| `book-covers` | Book cover images |
| `history-images` | History topic images |
| `scientist-images` | Scientist photos |
| `invention-images` | Invention images |
| `course-images` | Course thumbnails |
| `dua-images` | Dua category images |
| `news-images` | News article images |

---

## Step 2: Set Policies for EACH Bucket

For each bucket, go to **Policies tab** and run these SQL commands in **SQL Editor**:

### Option A: Quick Setup (All Buckets at Once)

Go to **SQL Editor** and run:

```sql
-- Allow anyone to read from all buckets (public access)
CREATE POLICY "Public Read Access"
ON storage.objects FOR SELECT
USING (true);

-- Allow anyone to upload to all buckets 
CREATE POLICY "Allow Uploads"
ON storage.objects FOR INSERT
WITH CHECK (true);

-- Allow anyone to update files
CREATE POLICY "Allow Updates"  
ON storage.objects FOR UPDATE
USING (true);

-- Allow anyone to delete files
CREATE POLICY "Allow Deletes"
ON storage.objects FOR DELETE
USING (true);
```

### Option B: Per-Bucket Setup (More Secure)

For each bucket (e.g., `profile-images`), click on the bucket → Policies:

1. **Click "New Policy"**
2. **Select "For full customization"**
3. Add these policies:

**SELECT (Read) Policy:**
- Policy name: `Public read`
- Allowed operation: SELECT
- Target roles: Leave empty (public)
- USING expression: `true`

**INSERT (Upload) Policy:**
- Policy name: `Allow uploads`
- Allowed operation: INSERT
- Target roles: Leave empty
- WITH CHECK expression: `true`

**UPDATE Policy:**
- Policy name: `Allow updates`
- Allowed operation: UPDATE
- USING expression: `true`

**DELETE Policy:**
- Policy name: `Allow deletes`
- Allowed operation: DELETE
- USING expression: `true`

---

## Step 3: Verify Policies

After adding policies, verify by:

1. Go to **Storage → [bucket name] → Policies**
2. You should see 4 policies (SELECT, INSERT, UPDATE, DELETE)

---

## Step 4: Fix Profile Image Upload Error

If you see **"new row violates row-level security policy"**:

1. Go to **SQL Editor**
2. Run this to check existing policies:
```sql
SELECT * FROM pg_policies WHERE tablename = 'objects';
```

3. If INSERT policy is missing, add it:
```sql
CREATE POLICY "Enable insert for all users" 
ON storage.objects FOR INSERT 
WITH CHECK (true);
```

---

## Folder Structure

Images are organized in folders within buckets:

```
profile-images/
  └── profile/
      └── {userId}_{timestamp}.jpg

religion-images/
  └── religions/
      └── {id}_{timestamp}.jpg

book-covers/
  └── books/
      └── {id}_{timestamp}.jpg
```

---

## Usage in App

Images uploaded to Supabase get a public URL like:
```
https://[project-id].supabase.co/storage/v1/object/public/[bucket]/[path]
```

This URL is stored in Firebase Firestore for the corresponding document.

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| "row violates row-level security policy" | Add INSERT policy with `WITH CHECK (true)` |
| "Bucket not found" | Create the bucket in Storage |
| "Permission denied" | Check policies are correctly set |
| Image not loading | Ensure bucket is marked as Public |

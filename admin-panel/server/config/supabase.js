import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
    console.error('⚠️  Missing Supabase credentials. Image uploads will not work.');
    console.error('   Add SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY to your .env file');
}

// Create Supabase client with service role key for server-side operations
export const supabase = createClient(
    supabaseUrl || '',
    supabaseServiceKey || '',
    {
        auth: {
            autoRefreshToken: false,
            persistSession: false
        }
    }
);

/**
 * Upload a file to Supabase Storage
 * @param {Buffer} fileBuffer - The file buffer to upload
 * @param {string} fileName - Original file name
 * @param {string} bucket - Supabase storage bucket name
 * @param {string} folder - Folder path within the bucket
 * @returns {Promise<{url: string|null, error: string|null}>}
 */
export async function uploadToSupabase(fileBuffer, fileName, bucket = 'book-covers', folder = 'uploads') {
    try {
        if (!supabaseUrl || !supabaseServiceKey) {
            return { url: null, error: 'Supabase not configured' };
        }

        // Generate unique file name
        const timestamp = Date.now();
        const ext = fileName.split('.').pop();
        const uniqueName = `${timestamp}-${Math.random().toString(36).substring(7)}.${ext}`;
        const filePath = `${folder}/${uniqueName}`;

        // Upload to Supabase
        const { data, error } = await supabase.storage
            .from(bucket)
            .upload(filePath, fileBuffer, {
                contentType: getContentType(ext),
                upsert: false
            });

        if (error) {
            console.error('Supabase upload error:', error);
            return { url: null, error: error.message };
        }

        // Get public URL
        const { data: urlData } = supabase.storage
            .from(bucket)
            .getPublicUrl(filePath);

        return { url: urlData.publicUrl, error: null };
    } catch (err) {
        console.error('Upload error:', err);
        return { url: null, error: err.message };
    }
}

/**
 * Delete a file from Supabase Storage using its public URL
 * @param {string} url - The public URL of the file
 * @param {string} bucket - The bucket name
 */
export async function deleteFromSupabase(url, bucket = 'profile-images') {
    try {
        if (!url || !url.includes(supabaseUrl)) return;

        // Extract file path from URL
        // URL format: https://[project].supabase.co/storage/v1/object/public/[bucket]/[folder]/[name]
        const urlParts = url.split(`/storage/v1/object/public/${bucket}/`);
        if (urlParts.length < 2) return;

        const filePath = urlParts[1];
        console.log(`[SUPABASE] Deleting file: ${filePath} from bucket: ${bucket}`);

        const { error } = await supabase.storage
            .from(bucket)
            .remove([filePath]);

        if (error) {
            console.error('Supabase delete error:', error);
        }
    } catch (err) {
        console.error('Delete error:', err);
    }
}

function getContentType(ext) {
    const types = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'webp': 'image/webp',
        'pdf': 'application/pdf',
        'mp3': 'audio/mpeg',
        'wav': 'audio/wav'
    };
    return types[ext?.toLowerCase()] || 'application/octet-stream';
}

export default supabase;

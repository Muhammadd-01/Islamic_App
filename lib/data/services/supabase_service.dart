import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Upload profile image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final extension = path.extension(imageFile.path);
      final fileName = 'profile_$userId$extension';
      final filePath = 'profiles/$fileName';

      // Upload file to Supabase Storage
      await client.storage
          .from('profile-images')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Replace if exists
            ),
          );

      // Get public URL
      final publicUrl = client.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete profile image from Supabase Storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the index of 'profile-images' bucket
      final bucketIndex = pathSegments.indexOf('profile-images');
      if (bucketIndex == -1) return;

      // Get the file path after the bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await client.storage.from('profile-images').remove([filePath]);
    } catch (e) {
      // Silently fail - image might not exist
      print('Failed to delete image: $e');
    }
  }

  /// Update profile image (delete old, upload new)
  Future<String> updateProfileImage(
    String userId,
    File newImageFile,
    String? oldImageUrl,
  ) async {
    // Delete old image if exists
    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      await deleteProfileImage(oldImageUrl);
    }

    // Upload new image
    return await uploadProfileImage(userId, newImageFile);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// Service for uploading images to Supabase Storage and saving URLs to Firestore
class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// The bucket name in Supabase Storage
  static const String _profileBucket = 'profile-images';

  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Pick and upload a profile image
  /// Returns the public URL of the uploaded image
  Future<String?> uploadProfileImage() async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    // Pick image from gallery
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile == null) return null;

    final bytes = await pickedFile.readAsBytes();
    return await uploadImageData(bytes, pickedFile.name, 'profile');
  }

  /// Upload an image data to Supabase Storage
  /// [bytes] - The image data to upload
  /// [fileName] - The original file name
  /// [folder] - The folder in the bucket (e.g., 'profile', 'posts')
  Future<String?> uploadImageData(
    Uint8List bytes,
    String fileName,
    String folder,
  ) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final ext = path.extension(fileName);
      final finalFileName =
          '${_userId}_${DateTime.now().millisecondsSinceEpoch}$ext';
      final filePath = '$folder/$finalFileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_profileBucket)
          .upload(
            filePath,
            bytes as dynamic,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_profileBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Save profile image URL to Firestore
  Future<void> saveProfileImageUrl(String imageUrl) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.collection('users').doc(_userId).set({
      'profileImageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Upload profile image and save URL to Firestore
  /// Returns the public URL of the uploaded image
  Future<String?> uploadAndSaveProfileImage() async {
    final imageUrl = await uploadProfileImage();
    if (imageUrl != null) {
      await saveProfileImageUrl(imageUrl);
    }
    return imageUrl;
  }

  /// Get user's profile image URL from Firestore
  Future<String?> getProfileImageUrl() async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      return doc.data()?['profileImageUrl'];
    } catch (e) {
      return null;
    }
  }

  /// Stream user's profile data including image URL
  Stream<Map<String, dynamic>?> watchUserProfile() {
    if (_userId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((doc) => doc.data());
  }
}

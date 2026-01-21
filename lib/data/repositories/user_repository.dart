import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final fb.FirebaseAuth _fbAuth = fb.FirebaseAuth.instance;

  String? get _userId =>
      _fbAuth.currentUser?.uid ?? _supabase.auth.currentUser?.id;

  /// Create user profile in Firestore after signup
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? name,
    String? phone,
    String? imageUrl,
    String role = 'user',
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(uid);

      // Check if user already exists to avoid overwriting
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': uid,
          'name': name ?? '',
          'email': email,
          'phone': phone ?? '',
          'bio': '',
          'location': '',
          'imageUrl': imageUrl ?? '',
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'bookmarks': [],
          'preferences': {'theme': 'system', 'language': 'en'},
        });
      }
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? phone,
    String? bio,
    String? location,
    String? imageUrl,
  }) async {
    final uid = _userId;
    if (uid == null) return;

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      updates['name'] = displayName;

      // Update metadata in the active provider
      if (_fbAuth.currentUser != null) {
        await _fbAuth.currentUser?.updateDisplayName(displayName);
      }
      if (_supabase.auth.currentUser != null) {
        await _supabase.auth.updateUser(
          UserAttributes(data: {'full_name': displayName}),
        );
      }
    }

    if (phone != null) updates['phone'] = phone;
    if (bio != null) updates['bio'] = bio;
    if (location != null) updates['location'] = location;
    if (imageUrl != null) {
      updates['imageUrl'] = imageUrl;
    }

    await _firestore.collection('users').doc(uid).update(updates);
  }

  Stream<DocumentSnapshot> getUserStream() {
    final uid = _userId;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _userId;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Check if user exists by email
  Future<bool> userExistsByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

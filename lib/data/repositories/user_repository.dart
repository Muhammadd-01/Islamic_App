import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth _fbAuth = fb.FirebaseAuth.instance;

  String? get _userId => _fbAuth.currentUser?.uid;

  /// Create user profile in Firestore after signup
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? name,
    String? phone,
    String? imageUrl,
    String? region,
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
          'region': region ?? 'Global',
          'role': role,
          'total_tasbeeh_count': 0,
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
    String? region,
  }) async {
    final uid = _userId;
    if (uid == null) return;

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      updates['name'] = displayName;

      // Update metadata in the active provider
      // Sync only with Firestore since Supabase auth is deprecated
      // and Firebase Auth display name update is not strictly necessary
      // if Firestore is the primary source of truth for user profiles.
    }

    if (phone != null) updates['phone'] = phone;
    if (bio != null) updates['bio'] = bio;
    if (location != null) updates['location'] = location;
    if (imageUrl != null) {
      updates['imageUrl'] = imageUrl;
    }
    if (region != null) {
      updates['region'] = region;
      updates['lastRegionUpdate'] = FieldValue.serverTimestamp();
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create user profile in Firestore after signup
  Future<void> createUserProfile(
    User user, {
    String? fullName,
    String? phone,
    String role = 'user',
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      // Check if user already exists to avoid overwriting
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'name': fullName ?? user.displayName ?? '',
          'email': user.email ?? '',
          'phone': phone ?? '',
          'bio': '',
          'location': '',
          'imageUrl': user.photoURL ?? '',
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'bookmarks': [],
          'preferences': {'theme': 'system', 'language': 'en'},
        });
      }
    } catch (e) {
      // Rethrow to let the UI handle the error
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
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      updates['name'] = displayName;
      await user.updateDisplayName(displayName);
    }
    if (phone != null) updates['phone'] = phone;
    if (bio != null) updates['bio'] = bio;
    if (location != null) updates['location'] = location;
    if (imageUrl != null) {
      updates['imageUrl'] = imageUrl;
      await user.updatePhotoURL(imageUrl);
    }

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  Stream<DocumentSnapshot> getUserStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
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

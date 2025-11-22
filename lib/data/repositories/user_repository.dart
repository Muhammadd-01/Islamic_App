import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserProfile(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    // Check if user already exists to avoid overwriting
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'bookmarks': [],
        'settings': {'theme': 'system', 'language': 'en'},
      });
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? bio,
    String? location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      updates['displayName'] = displayName;
      await user.updateDisplayName(displayName);
    }
    if (photoURL != null) {
      updates['photoURL'] = photoURL;
      await user.updatePhotoURL(photoURL);
    }
    if (bio != null) updates['bio'] = bio;
    if (location != null) updates['location'] = location;

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
}

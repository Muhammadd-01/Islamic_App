import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamic_app/domain/entities/bookmark.dart';

class BookmarkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get bookmarks stream for real-time updates
  Stream<List<Bookmark>> getBookmarksStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Bookmark.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  /// Get bookmarks as future (one-time fetch)
  Future<List<Bookmark>> getBookmarks() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Bookmark.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Add bookmark to Firestore
  Future<void> addBookmark(Bookmark bookmark) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Check if already exists
    final exists = await isBookmarked(bookmark.id, bookmark.type);
    if (exists) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc('${bookmark.type}_${bookmark.id}')
        .set(bookmark.toJson());
  }

  /// Remove bookmark from Firestore
  Future<void> removeBookmark(String id, String type) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc('${type}_$id')
        .delete();
  }

  /// Check if item is bookmarked
  Future<bool> isBookmarked(String id, String type) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc('${type}_$id')
        .get();

    return doc.exists;
  }

  /// Toggle bookmark (add if not exists, remove if exists)
  Future<void> toggleBookmark(Bookmark bookmark) async {
    final exists = await isBookmarked(bookmark.id, bookmark.type);
    if (exists) {
      await removeBookmark(bookmark.id, bookmark.type);
    } else {
      await addBookmark(bookmark);
    }
  }
}

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

final bookmarksStreamProvider = StreamProvider<List<Bookmark>>((ref) {
  final repo = ref.watch(bookmarkRepositoryProvider);
  return repo.getBookmarksStream();
});

final bookmarksProvider = FutureProvider<List<Bookmark>>((ref) async {
  final repo = ref.watch(bookmarkRepositoryProvider);
  return repo.getBookmarks();
});

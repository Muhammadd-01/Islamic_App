import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/book.dart';
import 'package:islamic_app/domain/repositories/library_repository.dart';

/// Firestore-based Library Repository
/// Books are managed from the admin panel
class FirestoreLibraryRepository implements LibraryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _booksCollection =>
      _firestore.collection('books');

  @override
  Future<List<Book>> getBooks() async {
    try {
      final snapshot = await _booksCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Use document ID as book ID
        return Book.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }

  @override
  Future<Book> getBookById(String id) async {
    final doc = await _booksCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Book not found');
    }
    final data = doc.data()!;
    data['id'] = doc.id;
    return Book.fromJson(data);
  }

  /// Stream of books for real-time updates
  Stream<List<Book>> getBooksStream() {
    return _booksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Book.fromJson(data);
          }).toList(),
        );
  }
}

// Providers
final firestoreLibraryRepositoryProvider = Provider<FirestoreLibraryRepository>(
  (ref) {
    return FirestoreLibraryRepository();
  },
);

final firestoreBooksProvider = StreamProvider<List<Book>>((ref) {
  final repo = ref.watch(firestoreLibraryRepositoryProvider);
  return repo.getBooksStream();
});

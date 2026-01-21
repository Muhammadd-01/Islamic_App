import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/news_item.dart';

class NewsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<NewsItem>> getNews() async {
    try {
      // Fetch all docs and sort in memory to avoid query failure if 'publishedAt' is missing
      final snapshot = await _firestore.collection('news').get();
      final items = snapshot.docs
          .map((doc) => NewsItem.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in-memory: descending order (newest first)
      items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return items;
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }

  Stream<List<NewsItem>> getNewsStream() {
    return _firestore.collection('news').snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => NewsItem.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in-memory: descending order (newest first)
      items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return items;
    });
  }
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

final newsProvider = FutureProvider<List<NewsItem>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getNews();
});

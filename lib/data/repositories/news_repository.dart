import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/news_item.dart';

class NewsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<NewsItem>> getNews() async {
    try {
      final snapshot = await _firestore
          .collection('news')
          .orderBy('publishedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => NewsItem.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }

  Stream<List<NewsItem>> getNewsStream() {
    return _firestore
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NewsItem.fromMap(doc.data(), doc.id))
              .toList();
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

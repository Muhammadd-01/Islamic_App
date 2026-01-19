import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/history_topic.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<HistoryTopic>> getHistoryTopics() async {
    try {
      final snapshot = await _firestore.collection('history').get();
      return snapshot.docs
          .map((doc) => HistoryTopic.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }

  Stream<List<HistoryTopic>> getHistoryStream() {
    return _firestore.collection('history').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => HistoryTopic.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final historyProvider = FutureProvider<List<HistoryTopic>>((ref) async {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.getHistoryTopics();
});

final historyStreamProvider = StreamProvider<List<HistoryTopic>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.getHistoryStream();
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/politics_topic.dart';

class PoliticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PoliticsTopic>> getPoliticsTopics() async {
    try {
      final snapshot = await _firestore.collection('politics').get();
      return snapshot.docs
          .map((doc) => PoliticsTopic.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching politics: $e');
      return [];
    }
  }

  Stream<List<PoliticsTopic>> getPoliticsStream() {
    return _firestore.collection('politics').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PoliticsTopic.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}

final politicsRepositoryProvider = Provider<PoliticsRepository>((ref) {
  return PoliticsRepository();
});

final politicsProvider = FutureProvider<List<PoliticsTopic>>((ref) async {
  final repo = ref.watch(politicsRepositoryProvider);
  return repo.getPoliticsTopics();
});

final politicsStreamProvider = StreamProvider<List<PoliticsTopic>>((ref) {
  final repo = ref.watch(politicsRepositoryProvider);
  return repo.getPoliticsStream();
});

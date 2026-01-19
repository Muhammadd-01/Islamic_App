import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/name_of_allah.dart';

class NamesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<NameOfAllah>> getNames() async {
    try {
      final snapshot = await _firestore
          .collection('names_of_allah')
          .orderBy('number')
          .get();
      return snapshot.docs
          .map((doc) => NameOfAllah.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching names: $e');
      return [];
    }
  }

  Stream<List<NameOfAllah>> getNamesStream() {
    return _firestore
        .collection('names_of_allah')
        .orderBy('number')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NameOfAllah.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}

final namesRepositoryProvider = Provider<NamesRepository>((ref) {
  return NamesRepository();
});

final namesProvider = FutureProvider<List<NameOfAllah>>((ref) async {
  final repo = ref.watch(namesRepositoryProvider);
  return repo.getNames();
});

final namesStreamProvider = StreamProvider<List<NameOfAllah>>((ref) {
  final repo = ref.watch(namesRepositoryProvider);
  return repo.getNamesStream();
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/scholar.dart';
import 'package:islamic_app/domain/repositories/scholars_repository.dart';

class ScholarsRepositoryImpl implements ScholarsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Scholar>> getScholars() async {
    try {
      final snapshot = await _firestore.collection('scholars').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Scholar(
          id: doc.id,
          name: data['name'] ?? 'Unknown Scholar',
          specialty: data['specialty'] ?? 'Islamic Scholar',
          bio: data['bio'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          isAvailableFor1on1: data['isAvailableFor1on1'] ?? false,
          consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
          whatsappNumber: data['whatsappNumber'] ?? '',
          isBooked: data['isBooked'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error fetching scholars: $e');
      return [];
    }
  }

  @override
  Future<Scholar> getScholarById(String id) async {
    try {
      final doc = await _firestore.collection('scholars').doc(id).get();
      if (!doc.exists) {
        throw Exception('Scholar not found');
      }
      final data = doc.data()!;
      return Scholar(
        id: doc.id,
        name: data['name'] ?? 'Unknown Scholar',
        specialty: data['specialty'] ?? 'Islamic Scholar',
        bio: data['bio'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        isAvailableFor1on1: data['isAvailableFor1on1'] ?? false,
        consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
        whatsappNumber: data['whatsappNumber'] ?? '',
        isBooked: data['isBooked'] ?? false,
      );
    } catch (e) {
      print('Error fetching scholar detail: $e');
      rethrow;
    }
  }

  Stream<List<Scholar>> getScholarsStream() {
    return _firestore.collection('scholars').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Scholar(
          id: doc.id,
          name: data['name'] ?? 'Unknown Scholar',
          specialty: data['specialty'] ?? 'Islamic Scholar',
          bio: data['bio'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          isAvailableFor1on1: data['isAvailableFor1on1'] ?? false,
          consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
          whatsappNumber: data['whatsappNumber'] ?? '',
          isBooked: data['isBooked'] ?? false,
        );
      }).toList();
    });
  }
}

final scholarsRepositoryProvider = Provider<ScholarsRepository>((ref) {
  return ScholarsRepositoryImpl();
});

final scholarsListProvider = FutureProvider<List<Scholar>>((ref) async {
  final repository = ref.watch(scholarsRepositoryProvider);
  return repository.getScholars();
});

final scholarsStreamProvider = StreamProvider<List<Scholar>>((ref) {
  final repository =
      ref.read(scholarsRepositoryProvider) as ScholarsRepositoryImpl;
  return repository.getScholarsStream();
});

final scholarDetailProvider = FutureProvider.family<Scholar, String>((
  ref,
  id,
) async {
  final repository = ref.watch(scholarsRepositoryProvider);
  return repository.getScholarById(id);
});

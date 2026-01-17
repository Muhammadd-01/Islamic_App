import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamic_app/domain/entities/invention.dart';
import 'package:islamic_app/domain/entities/scientist.dart';
import 'package:islamic_app/domain/repositories/muslim_scientists_repository.dart';

class MuslimScientistsRepositoryImpl implements MuslimScientistsRepository {
  final FirebaseFirestore _firestore;

  MuslimScientistsRepositoryImpl(this._firestore);

  @override
  Future<List<Invention>> getInventions() async {
    try {
      final snapshot = await _firestore.collection('inventions').get();
      return snapshot.docs
          .map((doc) => Invention.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Return empty list or rethrow depending on error handling strategy
      // For now, logging and return empty to avoid crash
      print('Error fetching inventions: $e');
      return [];
    }
  }

  @override
  Future<List<Scientist>> getScientists() async {
    try {
      final snapshot = await _firestore.collection('scientists').get();
      return snapshot.docs
          .map((doc) => Scientist.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching scientists: $e');
      return [];
    }
  }
}

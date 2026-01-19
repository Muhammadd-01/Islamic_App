import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamic_app/domain/entities/dua.dart';
import 'package:islamic_app/domain/entities/dua_category.dart';
import 'package:islamic_app/data/datasources/dua_data_source.dart';

class FirebaseDuaDataSource implements DuaDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<DuaCategory>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('dua_categories').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DuaCategory(id: doc.id, name: data['name'] ?? '');
      }).toList();
    } catch (e) {
      print('Error fetching dua categories: $e');
      return [];
    }
  }

  @override
  Future<List<Dua>> getDuas(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('duas')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Dua(
          id: int.tryParse(doc.id) ?? 0,
          arabic: data['arabic'] ?? '',
          translation: data['translation'] ?? '',
          reference: data['reference'] ?? '',
          audio: data['audio'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching duas: $e');
      return [];
    }
  }
}

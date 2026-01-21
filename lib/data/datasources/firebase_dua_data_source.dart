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
      if (snapshot.docs.isEmpty) {
        print(
          'DEBUG: No dua_categories found in Firestore. Using fallback list.',
        );
        // Fallback categories matching the Admin Panel's list
        return [
          DuaCategory(id: 'Morning', name: 'Morning'),
          DuaCategory(id: 'Evening', name: 'Evening'),
          DuaCategory(id: 'Prayer', name: 'Prayer'),
          DuaCategory(id: 'Travel', name: 'Travel'),
          DuaCategory(id: 'Food', name: 'Food'),
          DuaCategory(id: 'Sleep', name: 'Sleep'),
          DuaCategory(id: 'Protection', name: 'Protection'),
          DuaCategory(id: 'Forgiveness', name: 'Forgiveness'),
          DuaCategory(id: 'General', name: 'General'),
        ];
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DuaCategory(id: doc.id, name: data['name'] ?? doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching dua categories: $e');
      return [];
    }
  }

  @override
  Future<List<Dua>> getDuas(String categoryName) async {
    final cleanCategory = categoryName.trim();
    try {
      final snapshot = await _firestore
          .collection('duas')
          .where('category', isEqualTo: cleanCategory)
          .get();

      print('DEBUG: Fetching duas for category: "$cleanCategory"');
      print('DEBUG: Found ${snapshot.docs.length} docs');

      if (snapshot.docs.isEmpty) {
        // Fallback: try case-insensitive or partial match if needed,
        // but for now just log it.
        print(
          'DEBUG: No duas found. Check if Firestore has "category" field with value "$cleanCategory"',
        );
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Dua(
          id: doc.id,
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

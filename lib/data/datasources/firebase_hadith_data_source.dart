import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamic_app/data/datasources/hadith_data_source.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/domain/entities/hadith_category.dart';

class FirebaseHadithDataSource implements HadithDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<HadithCategory>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('hadith_categories').get();
      if (snapshot.docs.isEmpty) {
        return [
          HadithCategory(id: 'sahih-bukhari', name: 'Sahih Bukhari'),
          HadithCategory(id: 'sahih-muslim', name: 'Sahih Muslim'),
          HadithCategory(id: 'sunan-abu-dawood', name: 'Sunan Abu Dawood'),
          HadithCategory(id: 'sunan-al-tirmidhi', name: 'Jami at-Tirmidhi'),
        ];
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HadithCategory(id: doc.id, name: data['name'] ?? '');
      }).toList();
    } catch (e) {
      print('Error fetching hadith categories: $e');
      return [];
    }
  }

  @override
  Future<List<Hadith>> getHadiths(String bookId) async {
    try {
      final snapshot = await _firestore
          .collection('hadiths')
          .where('book', isEqualTo: bookId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // The entity expects id as int.
        // We'll try to parse a number from data or use a counter/hash if missing.
        final rawId = data['id'] ?? data['hadithNumber'];
        int hadithId;
        if (rawId is int) {
          hadithId = rawId;
        } else if (rawId is String) {
          hadithId = int.tryParse(rawId) ?? doc.id.hashCode;
        } else {
          hadithId = doc.id.hashCode;
        }

        return Hadith(
          id: hadithId,
          arabic:
              data['arabic'] ??
              data['content'] ??
              '', // Fallback to content if arabic field name differs
          english: data['english'] ?? data['translation'] ?? '',
          book: data['book'] ?? bookId,
          chapter: data['chapter'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching hadiths for $bookId: $e');
      return [];
    }
  }
}

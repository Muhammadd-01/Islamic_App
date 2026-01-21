import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamic_app/domain/entities/surah.dart';

class QuranRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Surah>> getSurahs() async {
    try {
      final snapshot = await _firestore
          .collection('quran')
          .orderBy('surahNumber')
          .get();

      if (snapshot.docs.isEmpty) {
        // We might want to keep the local fallback or external API fallback
        // to avoid blank screen if someone hasn't populated Firestore yet.
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Surah(
          number: data['surahNumber'] ?? 0,
          name: data['surahName'] ?? '',
          englishName: data['surahName'] ?? '', // Admin panel uses surahName
          englishNameTranslation: '',
          revelationType: data['revelationType'] ?? 'Meccan',
          numberOfAyahs: data['ayahs'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error fetching surahs: $e');
      return [];
    }
  }
}

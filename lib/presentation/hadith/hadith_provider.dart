import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/domain/entities/hadith_category.dart';

/// Hadith categories provider - fetches from Firebase 'hadith_categories' collection
final hadithCategoriesProvider = FutureProvider<List<HadithCategory>>((
  ref,
) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('hadith_categories')
        .get();

    if (snapshot.docs.isEmpty) {
      // Return default categories if none in Firebase
      return [
        HadithCategory(id: 'bukhari', name: 'Sahih Al-Bukhari'),
        HadithCategory(id: 'muslim', name: 'Sahih Muslim'),
        HadithCategory(id: 'abudawud', name: 'Sunan Abu Dawud'),
        HadithCategory(id: 'tirmidhi', name: 'Jami At-Tirmidhi'),
      ];
    }

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return HadithCategory(id: doc.id, name: data['name'] ?? '');
    }).toList();
  } catch (e) {
    print('Error fetching hadith categories: $e');
    return [
      HadithCategory(id: 'bukhari', name: 'Sahih Al-Bukhari'),
      HadithCategory(id: 'muslim', name: 'Sahih Muslim'),
    ];
  }
});

/// Hadith list provider - fetches from Firebase 'hadiths' collection by category
final hadithListProvider = FutureProvider.family<List<Hadith>, String>((
  ref,
  categoryId,
) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('hadiths')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Hadith(
        id: int.tryParse(data['hadithNumber']?.toString() ?? doc.id) ?? 0,
        arabic: data['arabic'] ?? '',
        english: data['english'] ?? data['translation'] ?? '',
        book: categoryId,
        chapter: data['chapter'],
      );
    }).toList();
  } catch (e) {
    print('Error fetching hadiths: $e');
    return [];
  }
});

/// Daily hadith provider
final dailyHadithProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('hadiths')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  } catch (e) {
    print('Error fetching daily hadith: $e');
    return null;
  }
});

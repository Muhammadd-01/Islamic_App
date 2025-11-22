import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/services/hadith_service.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/domain/entities/hadith_category.dart';

final hadithServiceProvider = Provider<HadithService>((ref) {
  return HadithService();
});

final dailyHadithProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(hadithServiceProvider);
  return await service.getRandomHadith();
});

final hadithCategoriesProvider = FutureProvider<List<HadithCategory>>((
  ref,
) async {
  // Mock categories for now
  return [
    HadithCategory(id: 'bukhari', name: 'Sahih Al-Bukhari'),
    HadithCategory(id: 'muslim', name: 'Sahih Muslim'),
    HadithCategory(id: 'abudawud', name: 'Sunan Abu Dawud'),
    HadithCategory(id: 'tirmidhi', name: 'Jami At-Tirmidhi'),
  ];
});

final hadithListProvider = FutureProvider.family<List<Hadith>, String>((
  ref,
  bookId,
) async {
  final service = ref.watch(hadithServiceProvider);
  final rawHadiths = await service.getHadiths(bookId);

  return rawHadiths.map((data) {
    return Hadith(
      id: data['hadith_number'],
      arabic: data['text_ar'],
      english: data['text_en'],
      book: bookId,
      chapter: data['narrator'], // Using narrator as chapter for now or null
    );
  }).toList();
});

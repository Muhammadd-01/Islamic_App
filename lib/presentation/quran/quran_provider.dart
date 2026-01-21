import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/repositories/quran_repository.dart';
import 'package:islamic_app/domain/entities/surah.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getSurahs();
});

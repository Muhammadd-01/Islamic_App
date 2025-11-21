import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/datasources/hadith_data_source.dart';
import 'package:islamic_app/data/repositories/hadith_repository_impl.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/domain/entities/hadith_category.dart';
import 'package:islamic_app/domain/repositories/hadith_repository.dart';

final hadithDataSourceProvider = Provider<HadithDataSource>((ref) {
  return LocalHadithDataSource();
});

final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  return HadithRepositoryImpl(ref.watch(hadithDataSourceProvider));
});

final hadithCategoriesProvider = FutureProvider<List<HadithCategory>>((
  ref,
) async {
  return ref.watch(hadithRepositoryProvider).getCategories();
});

final hadithListProvider = FutureProvider.family<List<Hadith>, String>((
  ref,
  bookId,
) async {
  return ref.watch(hadithRepositoryProvider).getHadiths(bookId);
});

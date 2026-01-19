import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/datasources/dua_data_source.dart';
import 'package:islamic_app/data/datasources/firebase_dua_data_source.dart';
import 'package:islamic_app/data/repositories/dua_repository_impl.dart';
import 'package:islamic_app/domain/entities/dua.dart';
import 'package:islamic_app/domain/entities/dua_category.dart';
import 'package:islamic_app/domain/repositories/dua_repository.dart';

final duaDataSourceProvider = Provider<DuaDataSource>((ref) {
  return FirebaseDuaDataSource();
});

final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  return DuaRepositoryImpl(ref.watch(duaDataSourceProvider));
});

final duaCategoriesProvider = FutureProvider<List<DuaCategory>>((ref) async {
  return ref.watch(duaRepositoryProvider).getCategories();
});

final duaListProvider = FutureProvider.family<List<Dua>, String>((
  ref,
  categoryId,
) async {
  return ref.watch(duaRepositoryProvider).getDuas(categoryId);
});

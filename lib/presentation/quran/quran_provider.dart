import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/providers/api_provider.dart';
import 'package:islamic_app/domain/entities/surah.dart';

final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final api = ref.read(mockApiServiceProvider);
  final data = await api.getSurahs();
  return data.map((e) => Surah.fromJson(e)).toList();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/datasources/quran_audio_data_source.dart';
import 'package:islamic_app/data/repositories/quran_audio_repository_impl.dart';
import 'package:islamic_app/domain/entities/quran_audio.dart';
import 'package:islamic_app/domain/repositories/quran_audio_repository.dart';

final quranAudioDataSourceProvider = Provider<QuranAudioDataSource>((ref) {
  return LocalQuranAudioDataSource();
});

final quranAudioRepositoryProvider = Provider<QuranAudioRepository>((ref) {
  return QuranAudioRepositoryImpl(ref.watch(quranAudioDataSourceProvider));
});

final recitersProvider = FutureProvider<List<Reciter>>((ref) async {
  return ref.watch(quranAudioRepositoryProvider).getReciters();
});

final selectedReciterProvider = FutureProvider<String?>((ref) async {
  return ref.watch(quranAudioRepositoryProvider).getSelectedReciter();
});

final surahAudioProvider = FutureProvider.family<SurahAudio, String>((
  ref,
  surahId,
) async {
  return ref.watch(quranAudioRepositoryProvider).getSurahAudio(surahId);
});

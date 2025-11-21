import 'package:islamic_app/data/datasources/quran_audio_data_source.dart';
import 'package:islamic_app/domain/entities/quran_audio.dart';
import 'package:islamic_app/domain/repositories/quran_audio_repository.dart';

class QuranAudioRepositoryImpl implements QuranAudioRepository {
  final QuranAudioDataSource dataSource;

  QuranAudioRepositoryImpl(this.dataSource);

  @override
  Future<List<Reciter>> getReciters() async {
    return await dataSource.getReciters();
  }

  @override
  Future<SurahAudio> getSurahAudio(String surahId) async {
    return await dataSource.getSurahAudio(surahId);
  }

  @override
  Future<String?> getSelectedReciter() async {
    return await dataSource.getSelectedReciter();
  }

  @override
  Future<void> setSelectedReciter(String reciterId) async {
    await dataSource.setSelectedReciter(reciterId);
  }

  @override
  Future<Map<String, int>?> getLastPlayedAyah() async {
    return await dataSource.getLastPlayedAyah();
  }

  @override
  Future<void> saveLastPlayedAyah(String surahId, int ayahIndex) async {
    await dataSource.saveLastPlayedAyah(surahId, ayahIndex);
  }
}

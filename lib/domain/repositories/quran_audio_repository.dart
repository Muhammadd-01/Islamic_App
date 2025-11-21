import 'package:islamic_app/domain/entities/quran_audio.dart';

abstract class QuranAudioRepository {
  Future<List<Reciter>> getReciters();
  Future<SurahAudio> getSurahAudio(String surahId);
  Future<String?> getSelectedReciter();
  Future<void> setSelectedReciter(String reciterId);
  Future<Map<String, int>?> getLastPlayedAyah();
  Future<void> saveLastPlayedAyah(String surahId, int ayahIndex);
}

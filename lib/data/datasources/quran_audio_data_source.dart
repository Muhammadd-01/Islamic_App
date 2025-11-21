import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/domain/entities/quran_audio.dart';

abstract class QuranAudioDataSource {
  Future<List<Reciter>> getReciters();
  Future<SurahAudio> getSurahAudio(String surahId);
  Future<String?> getSelectedReciter();
  Future<void> setSelectedReciter(String reciterId);
  Future<Map<String, int>?> getLastPlayedAyah();
  Future<void> saveLastPlayedAyah(String surahId, int ayahIndex);
}

class LocalQuranAudioDataSource implements QuranAudioDataSource {
  static const String _reciterKey = 'selected_reciter';
  static const String _lastPlayedKey = 'last_played_ayah';

  @override
  Future<List<Reciter>> getReciters() async {
    final String response = await rootBundle.loadString(
      'assets/api/audio/reciters.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((e) => Reciter.fromJson(e)).toList();
  }

  @override
  Future<SurahAudio> getSurahAudio(String surahId) async {
    final String response = await rootBundle.loadString(
      'assets/api/audio/surah_audio_urls.json',
    );
    final Map<String, dynamic> data = json.decode(response);
    return SurahAudio.fromJson(surahId, data[surahId]);
  }

  @override
  Future<String?> getSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_reciterKey);
  }

  @override
  Future<void> setSelectedReciter(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciterId);
  }

  @override
  Future<Map<String, int>?> getLastPlayedAyah() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_lastPlayedKey);
    if (jsonString != null) {
      final Map<String, dynamic> data = json.decode(jsonString);
      return {'surahId': data['surahId'], 'ayahIndex': data['ayahIndex']};
    }
    return null;
  }

  @override
  Future<void> saveLastPlayedAyah(String surahId, int ayahIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode({
      'surahId': surahId,
      'ayahIndex': ayahIndex,
    });
    await prefs.setString(_lastPlayedKey, jsonString);
  }
}

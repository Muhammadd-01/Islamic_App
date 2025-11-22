import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranService {
  static const String _baseUrl = 'http://api.alquran.cloud/v1';

  Future<Map<String, dynamic>> getSurah(int number) async {
    final url = Uri.parse('$_baseUrl/surah/$number/ar.alafasy');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      } else {
        throw Exception('Failed to load Surah');
      }
    } catch (e) {
      throw Exception('Error fetching Surah: $e');
    }
  }

  Future<List<dynamic>> getAllSurahs() async {
    final url = Uri.parse('$_baseUrl/surah');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      } else {
        throw Exception('Failed to load Surahs');
      }
    } catch (e) {
      throw Exception('Error fetching Surahs: $e');
    }
  }
}

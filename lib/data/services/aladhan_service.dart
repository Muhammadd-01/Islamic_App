import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AladhanService {
  static const String _baseUrl = 'http://api.aladhan.com/v1';

  Future<Map<String, dynamic>> getPrayerTimes(
    double latitude,
    double longitude,
  ) async {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final url = Uri.parse(
      '$_baseUrl/timings/$date?latitude=$latitude&longitude=$longitude&method=2',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['timings'];
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  Future<Map<String, dynamic>> getHijriDate(
    double latitude,
    double longitude,
  ) async {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final url = Uri.parse(
      '$_baseUrl/gToH/$date?latitude=$latitude&longitude=$longitude',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['hijri'];
      } else {
        throw Exception('Failed to load Hijri date');
      }
    } catch (e) {
      throw Exception('Error fetching Hijri date: $e');
    }
  }
}

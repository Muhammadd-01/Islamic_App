import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:islamic_app/core/constants/api_constants.dart';
import 'package:islamic_app/data/services/api_config_service.dart';

class InspirationItem {
  final String text;
  final String? author;
  final String? source;

  InspirationItem({required this.text, this.author, this.source});

  factory InspirationItem.fromJson(Map<String, dynamic> json) {
    return InspirationItem(
      text: json['text'] ?? '',
      author: json['author'],
      source: json['source'],
    );
  }
}

class DailyInspiration {
  final InspirationItem? quote;
  final InspirationItem? hadith;
  final InspirationItem? ayah;
  final bool notified;

  DailyInspiration({this.quote, this.hadith, this.ayah, this.notified = false});

  factory DailyInspiration.fromJson(Map<String, dynamic> json) {
    return DailyInspiration(
      quote: json['quote'] != null
          ? InspirationItem.fromJson(json['quote'])
          : null,
      hadith: json['hadith'] != null
          ? InspirationItem.fromJson(json['hadith'])
          : null,
      ayah: json['ayah'] != null
          ? InspirationItem.fromJson(json['ayah'])
          : null,
      notified: json['notified'] ?? false,
    );
  }
}

final dailyInspirationProvider = FutureProvider<DailyInspiration?>((ref) async {
  try {
    final dynamicBaseUrl = ref.read(apiUrlProvider);
    final response = await http.get(
      Uri.parse(ApiConstants.getDailyInspirationUrl(dynamicBaseUrl)),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['message'] == 'No inspiration found for today') return null;
      return DailyInspiration.fromJson(data);
    }
    return null;
  } catch (e) {
    print('Error fetching daily inspiration: $e');
    return null;
  }
});

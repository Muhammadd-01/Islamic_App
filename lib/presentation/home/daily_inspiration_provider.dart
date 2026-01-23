import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
    // Replace with your actual server URL
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/daily-inspirations/today'),
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

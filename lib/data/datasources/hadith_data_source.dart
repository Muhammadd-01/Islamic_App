import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/domain/entities/hadith_category.dart';

abstract class HadithDataSource {
  Future<List<HadithCategory>> getCategories();
  Future<List<Hadith>> getHadiths(String bookId);
}

class LocalHadithDataSource implements HadithDataSource {
  @override
  Future<List<HadithCategory>> getCategories() async {
    final String response = await rootBundle.loadString(
      'assets/api/hadith/categories.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => HadithCategory.fromJson(json)).toList();
  }

  @override
  Future<List<Hadith>> getHadiths(String bookId) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/api/hadith/$bookId.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Hadith.fromJson(json)).toList();
    } catch (e) {
      // Fallback or empty list if file not found (e.g. for books we haven't mocked yet)
      return [];
    }
  }
}

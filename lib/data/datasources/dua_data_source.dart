import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_app/domain/entities/dua.dart';
import 'package:islamic_app/domain/entities/dua_category.dart';

abstract class DuaDataSource {
  Future<List<DuaCategory>> getCategories();
  Future<List<Dua>> getDuas(String categoryId);
}

class LocalDuaDataSource implements DuaDataSource {
  @override
  Future<List<DuaCategory>> getCategories() async {
    final String response = await rootBundle.loadString(
      'assets/api/dua/categories.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => DuaCategory.fromJson(json)).toList();
  }

  @override
  Future<List<Dua>> getDuas(String categoryId) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/api/dua/$categoryId.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Dua.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

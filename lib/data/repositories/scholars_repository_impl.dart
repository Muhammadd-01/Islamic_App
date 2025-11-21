import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/scholar.dart';
import 'package:islamic_app/domain/repositories/scholars_repository.dart';

class ScholarsRepositoryImpl implements ScholarsRepository {
  @override
  Future<List<Scholar>> getScholars() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    final String response = await rootBundle.loadString(
      'assets/api/scholars/scholars.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Scholar.fromJson(json)).toList();
  }

  @override
  Future<Scholar> getScholarById(String id) async {
    final scholars = await getScholars();
    return scholars.firstWhere((scholar) => scholar.id == id);
  }
}

final scholarsRepositoryProvider = Provider<ScholarsRepository>((ref) {
  return ScholarsRepositoryImpl();
});

final scholarsListProvider = FutureProvider<List<Scholar>>((ref) async {
  final repository = ref.watch(scholarsRepositoryProvider);
  return repository.getScholars();
});

final scholarDetailProvider = FutureProvider.family<Scholar, String>((
  ref,
  id,
) async {
  final repository = ref.watch(scholarsRepositoryProvider);
  return repository.getScholarById(id);
});

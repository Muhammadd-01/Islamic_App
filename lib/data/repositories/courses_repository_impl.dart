import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/course.dart';
import 'package:islamic_app/domain/repositories/courses_repository.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  @override
  Future<List<Course>> getCourses() async {
    final String response = await rootBundle.loadString(
      'assets/api/courses/courses.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Course.fromJson(json)).toList();
  }
}

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepositoryImpl();
});

final coursesListProvider = FutureProvider<List<Course>>((ref) async {
  final repository = ref.watch(coursesRepositoryProvider);
  return repository.getCourses();
});

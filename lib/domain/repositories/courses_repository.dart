import 'package:islamic_app/domain/entities/course.dart';

abstract class CoursesRepository {
  Future<List<Course>> getCourses();
}

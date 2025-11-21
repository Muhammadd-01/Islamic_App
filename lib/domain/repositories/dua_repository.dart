import 'package:islamic_app/domain/entities/dua.dart';
import 'package:islamic_app/domain/entities/dua_category.dart';

abstract class DuaRepository {
  Future<List<DuaCategory>> getCategories();
  Future<List<Dua>> getDuas(String categoryId);
}

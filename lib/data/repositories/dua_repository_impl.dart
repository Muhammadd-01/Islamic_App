import 'package:islamic_app/data/datasources/dua_data_source.dart';
import 'package:islamic_app/domain/entities/dua.dart';
import 'package:islamic_app/domain/entities/dua_category.dart';
import 'package:islamic_app/domain/repositories/dua_repository.dart';

class DuaRepositoryImpl implements DuaRepository {
  final DuaDataSource dataSource;

  DuaRepositoryImpl(this.dataSource);

  @override
  Future<List<DuaCategory>> getCategories() async {
    return await dataSource.getCategories();
  }

  @override
  Future<List<Dua>> getDuas(String categoryId) async {
    return await dataSource.getDuas(categoryId);
  }
}

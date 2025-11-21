import 'package:islamic_app/data/datasources/hadith_data_source.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/domain/entities/hadith_category.dart';
import 'package:islamic_app/domain/repositories/hadith_repository.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithDataSource dataSource;

  HadithRepositoryImpl(this.dataSource);

  @override
  Future<List<HadithCategory>> getCategories() async {
    return await dataSource.getCategories();
  }

  @override
  Future<List<Hadith>> getHadiths(String bookId) async {
    return await dataSource.getHadiths(bookId);
  }
}

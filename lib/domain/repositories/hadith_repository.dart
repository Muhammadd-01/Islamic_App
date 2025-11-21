import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/domain/entities/hadith_category.dart';

abstract class HadithRepository {
  Future<List<HadithCategory>> getCategories();
  Future<List<Hadith>> getHadiths(String bookId);
}

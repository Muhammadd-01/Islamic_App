import 'package:islamic_app/domain/entities/article.dart';

abstract class ArticlesRepository {
  Future<List<Article>> getArticles();
  Future<Article?> getArticle(int id);
}

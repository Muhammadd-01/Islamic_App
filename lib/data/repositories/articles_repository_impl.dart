import 'package:islamic_app/data/datasources/articles_data_source.dart';
import 'package:islamic_app/domain/entities/article.dart';
import 'package:islamic_app/domain/repositories/articles_repository.dart';

class ArticlesRepositoryImpl implements ArticlesRepository {
  final ArticlesDataSource dataSource;

  ArticlesRepositoryImpl(this.dataSource);

  @override
  Future<List<Article>> getArticles() async {
    return await dataSource.getArticles();
  }

  @override
  Future<Article?> getArticle(int id) async {
    return await dataSource.getArticle(id);
  }
}

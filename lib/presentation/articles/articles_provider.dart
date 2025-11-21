import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/datasources/articles_data_source.dart';
import 'package:islamic_app/data/repositories/articles_repository_impl.dart';
import 'package:islamic_app/domain/entities/article.dart';
import 'package:islamic_app/domain/repositories/articles_repository.dart';

final articlesDataSourceProvider = Provider<ArticlesDataSource>((ref) {
  return LocalArticlesDataSource();
});

final articlesRepositoryProvider = Provider<ArticlesRepository>((ref) {
  return ArticlesRepositoryImpl(ref.watch(articlesDataSourceProvider));
});

final articlesListProvider = FutureProvider<List<Article>>((ref) async {
  return ref.watch(articlesRepositoryProvider).getArticles();
});

final articleDetailProvider = FutureProvider.family<Article?, int>((
  ref,
  id,
) async {
  return ref.watch(articlesRepositoryProvider).getArticle(id);
});

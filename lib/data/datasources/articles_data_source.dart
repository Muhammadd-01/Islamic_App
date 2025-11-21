import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_app/domain/entities/article.dart';

abstract class ArticlesDataSource {
  Future<List<Article>> getArticles();
  Future<Article?> getArticle(int id);
}

class LocalArticlesDataSource implements ArticlesDataSource {
  @override
  Future<List<Article>> getArticles() async {
    final String response = await rootBundle.loadString(
      'assets/api/articles/articles.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Article.fromJson(json)).toList();
  }

  @override
  Future<Article?> getArticle(int id) async {
    final articles = await getArticles();
    try {
      return articles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }
}

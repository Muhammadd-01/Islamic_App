import 'package:cloud_firestore/cloud_firestore.dart';

class NewsItem {
  final String id;
  final String title;
  final String description;
  final String url;
  final String source;
  final String? imageUrl;
  final String category;
  final DateTime publishedAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    this.imageUrl,
    this.category = 'general',
    required this.publishedAt,
  });

  factory NewsItem.fromMap(Map<String, dynamic> map, String id) {
    final rawPublishedAt = map['publishedAt'] ?? map['createdAt'];
    DateTime publishedDate;

    if (rawPublishedAt is Timestamp) {
      publishedDate = rawPublishedAt.toDate();
    } else if (rawPublishedAt is String) {
      publishedDate = DateTime.tryParse(rawPublishedAt) ?? DateTime.now();
    } else {
      publishedDate = DateTime.now();
    }

    return NewsItem(
      id: id,
      title: map['title'] ?? '',
      // Map 'content' from Admin Panel to 'description' in App
      description: map['description'] ?? map['content'] ?? '',
      url: map['url'] ?? '',
      source: map['source'] ?? 'Unknown',
      imageUrl: map['imageUrl'],
      category: map['category'] ?? 'general',
      publishedAt: publishedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'source': source,
      'imageUrl': imageUrl,
      'category': category,
      'publishedAt': publishedAt,
    };
  }
}

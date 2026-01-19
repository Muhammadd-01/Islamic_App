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
    return NewsItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      source: map['source'] ?? 'Unknown',
      imageUrl: map['imageUrl'],
      category: map['category'] ?? 'general',
      publishedAt: map['publishedAt'] != null
          ? (map['publishedAt'] as dynamic).toDate()
          : DateTime.now(),
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

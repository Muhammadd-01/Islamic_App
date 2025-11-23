class Bookmark {
  final String id;
  final String type; // 'quran', 'hadith', 'dua', 'qa', 'article'
  final String title;
  final String subtitle;
  final String content; // Full content of the bookmark
  final String route;
  final DateTime timestamp;
  final String? sourceUrl; // Optional URL to source
  final Map<String, dynamic>?
  metadata; // Additional data (surah number, ayah, etc.)

  Bookmark({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.route,
    required this.timestamp,
    this.sourceUrl,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'route': route,
      'timestamp': timestamp.toIso8601String(),
      'sourceUrl': sourceUrl,
      'metadata': metadata,
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      subtitle: json['subtitle'],
      content: json['content'] ?? '',
      route: json['route'],
      timestamp: DateTime.parse(json['timestamp']),
      sourceUrl: json['sourceUrl'],
      metadata: json['metadata'],
    );
  }
}

class Bookmark {
  final String id;
  final String type; // 'quran', 'hadith', 'dua', 'qa'
  final String title;
  final String subtitle;
  final String route;
  final DateTime timestamp;

  Bookmark({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'route': route,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      subtitle: json['subtitle'],
      route: json['route'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

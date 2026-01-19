class HistoryTopic {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String documentUrl;
  final String era;
  final String imageUrl;
  final String category; // 'islamic' | 'western'

  HistoryTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.documentUrl,
    required this.era,
    required this.imageUrl,
    required this.category,
  });

  factory HistoryTopic.fromMap(Map<String, dynamic> map, String id) {
    return HistoryTopic(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      documentUrl: map['documentUrl'] ?? '',
      era: map['era'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'islamic',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'documentUrl': documentUrl,
      'era': era,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}

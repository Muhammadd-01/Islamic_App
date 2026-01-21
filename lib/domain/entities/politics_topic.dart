class PoliticsTopic {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String documentUrl;
  final String category; // 'islamic' | 'western'

  PoliticsTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.documentUrl,
    required this.category,
  });

  factory PoliticsTopic.fromMap(Map<String, dynamic> map, String id) {
    return PoliticsTopic(
      id: id,
      title: map['title'] ?? '',
      // Map 'content' from Admin Panel to 'description' in App
      description: map['description'] ?? map['content'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      documentUrl: map['documentUrl'] ?? '',
      category: map['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'documentUrl': documentUrl,
      'category': category,
    };
  }
}

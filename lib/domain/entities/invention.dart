class Invention {
  final String id;
  final String title;
  final String description;
  final String discoveredBy; // Name of discoverer
  final String? refinedBy; // Name of refiner (optional)
  final String year;
  final String imageUrl;
  final List<String> details; // Bullet points of history
  final String? videoUrl;
  final String? documentUrl;
  final String contentType; // 'video' or 'document'

  Invention({
    required this.id,
    required this.title,
    required this.description,
    required this.discoveredBy,
    this.refinedBy,
    required this.year,
    required this.imageUrl,
    required this.details,
    this.videoUrl,
    this.documentUrl,
    this.contentType = 'video',
  });

  factory Invention.fromMap(Map<String, dynamic> map, String id) {
    return Invention(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discoveredBy: map['discoveredBy'] ?? '',
      refinedBy: map['refinedBy'],
      year: map['year'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      details: List<String>.from(map['details'] ?? []),
      videoUrl: map['videoUrl'],
      documentUrl: map['documentUrl'],
      contentType: map['contentType'] ?? 'video',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'discoveredBy': discoveredBy,
      'refinedBy': refinedBy,
      'year': year,
      'imageUrl': imageUrl,
      'details': details,
      'videoUrl': videoUrl,
      'documentUrl': documentUrl,
      'contentType': contentType,
    };
  }
}

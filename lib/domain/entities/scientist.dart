class Scientist {
  final String id;
  final String name;
  final String bio;
  final String field; // e.g. Medicine, Astronomy
  final String imageUrl;
  final String birthDeath; // e.g. 780 - 850 AD
  final List<String> achievements;
  final String? videoUrl;
  final String? documentUrl;
  final String contentType; // 'video' or 'document'

  Scientist({
    required this.id,
    required this.name,
    required this.bio,
    required this.field,
    required this.imageUrl,
    required this.birthDeath,
    required this.achievements,
    this.videoUrl,
    this.documentUrl,
    this.contentType = 'video',
  });

  factory Scientist.fromMap(Map<String, dynamic> map, String id) {
    return Scientist(
      id: id,
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      field: map['field'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      birthDeath: map['birthDeath'] ?? '',
      achievements: List<String>.from(map['achievements'] ?? []),
      videoUrl: map['videoUrl'],
      documentUrl: map['documentUrl'],
      contentType: map['contentType'] ?? 'video',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'field': field,
      'imageUrl': imageUrl,
      'birthDeath': birthDeath,
      'achievements': achievements,
      'videoUrl': videoUrl,
      'documentUrl': documentUrl,
      'contentType': contentType,
    };
  }
}

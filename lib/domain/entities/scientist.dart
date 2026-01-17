class Scientist {
  final String id;
  final String name;
  final String bio;
  final String field; // e.g. Medicine, Astronomy
  final String imageUrl;
  final String birthDeath; // e.g. 780 - 850 AD
  final List<String> achievements;

  Scientist({
    required this.id,
    required this.name,
    required this.bio,
    required this.field,
    required this.imageUrl,
    required this.birthDeath,
    required this.achievements,
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
    };
  }
}

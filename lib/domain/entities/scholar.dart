class Scholar {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String imageUrl;
  final bool isAvailableFor1on1;
  final double consultationFee;

  const Scholar({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.imageUrl,
    required this.isAvailableFor1on1,
    required this.consultationFee,
  });

  factory Scholar.fromJson(Map<String, dynamic> json) {
    return Scholar(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      bio: json['bio'] as String,
      imageUrl: json['imageUrl'] as String,
      isAvailableFor1on1: json['isAvailableFor1on1'] as bool,
      consultationFee: (json['consultationFee'] as num).toDouble(),
    );
  }
}

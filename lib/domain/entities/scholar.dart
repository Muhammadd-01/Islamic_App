class Scholar {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String imageUrl;
  final bool isAvailableFor1on1;
  final double consultationFee;

  final String whatsappNumber;
  final bool isBooked;

  const Scholar({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.imageUrl,
    required this.isAvailableFor1on1,
    required this.consultationFee,
    required this.whatsappNumber,
    required this.isBooked,
  });

  factory Scholar.fromJson(Map<String, dynamic> json) {
    return Scholar(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Scholar',
      specialty: json['specialty'] as String? ?? 'General',
      bio: json['bio'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      isAvailableFor1on1: json['isAvailableFor1on1'] == true,
      consultationFee: (json['consultationFee'] as num? ?? 0.0).toDouble(),
      whatsappNumber: json['whatsappNumber'] as String? ?? '',
      isBooked: json['isBooked'] == true,
    );
  }
}

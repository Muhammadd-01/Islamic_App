class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? imageUrl;
  final String? region;
  final DateTime? lastRegionUpdate;
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    this.imageUrl,
    this.region,
    this.lastRegionUpdate,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'imageUrl': imageUrl,
      'region': region,
      'lastRegionUpdate': lastRegionUpdate != null
          ? lastRegionUpdate!.toIso8601String()
          : null,
      'role': role,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phone: map['phone'],
      imageUrl: map['imageUrl'],
      region: map['region'],
      lastRegionUpdate: map['lastRegionUpdate'] != null
          ? DateTime.tryParse(map['lastRegionUpdate'].toString())
          : null,
      role: map['role'] ?? 'user',
    );
  }
}

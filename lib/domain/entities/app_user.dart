class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? imageUrl;
  final String? region;
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    this.imageUrl,
    this.region,
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
      role: map['role'] ?? 'user',
    );
  }
}

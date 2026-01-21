class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? imageUrl;
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    this.imageUrl,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'imageUrl': imageUrl,
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
      role: map['role'] ?? 'user',
    );
  }
}

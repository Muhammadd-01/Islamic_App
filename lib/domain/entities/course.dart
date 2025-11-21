class Course {
  final String id;
  final String title;
  final String university;
  final String description;
  final String imageUrl;
  final String affiliationUrl;
  final String duration;
  final String level;

  Course({
    required this.id,
    required this.title,
    required this.university,
    required this.description,
    required this.imageUrl,
    required this.affiliationUrl,
    required this.duration,
    required this.level,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      university: json['university'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      affiliationUrl: json['affiliationUrl'],
      duration: json['duration'],
      level: json['level'],
    );
  }
}

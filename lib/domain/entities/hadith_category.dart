class HadithCategory {
  final String id;
  final String name;

  HadithCategory({required this.id, required this.name});

  factory HadithCategory.fromJson(Map<String, dynamic> json) {
    return HadithCategory(id: json['id'], name: json['name']);
  }
}

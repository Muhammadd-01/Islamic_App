class DuaCategory {
  final String id;
  final String name;

  DuaCategory({required this.id, required this.name});

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(id: json['id'], name: json['name']);
  }
}

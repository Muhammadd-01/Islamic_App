class NameOfAllah {
  final String id;
  final String name; // Transliteration
  final String meaning;
  final String arabic;
  final String description;
  final int number; // 1-99

  NameOfAllah({
    required this.id,
    required this.name,
    required this.meaning,
    required this.arabic,
    this.description = '',
    this.number = 0,
  });

  factory NameOfAllah.fromMap(Map<String, dynamic> map, String id) {
    return NameOfAllah(
      id: id,
      name: map['name'] ?? '',
      meaning: map['meaning'] ?? '',
      arabic: map['arabic'] ?? '',
      description: map['description'] ?? '',
      number: map['number'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'meaning': meaning,
      'arabic': arabic,
      'description': description,
      'number': number,
    };
  }
}

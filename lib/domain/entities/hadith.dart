class Hadith {
  final int id;
  final String arabic;
  final String english;
  final String book;
  final String? chapter;

  Hadith({
    required this.id,
    required this.arabic,
    required this.english,
    required this.book,
    this.chapter,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'],
      arabic: json['arabic'],
      english: json['english'],
      book: json['book'],
      chapter: json['chapter'],
    );
  }
}

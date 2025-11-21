class Article {
  final int id;
  final String title;
  final String image;
  final String category;
  final String date;
  final String author;
  final String summary;
  final List<String> content;

  Article({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.date,
    required this.author,
    required this.summary,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      category: json['category'],
      date: json['date'],
      author: json['author'] ?? 'Unknown',
      summary: json['summary'],
      content: List<String>.from(json['content']),
    );
  }
}

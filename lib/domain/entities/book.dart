class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final double price;
  final bool isFree;
  final double rating;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.price,
    required this.isFree,
    required this.rating,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      coverUrl: json['coverUrl'] as String,
      price: (json['price'] as num).toDouble(),
      isFree: json['isFree'] as bool,
      rating: (json['rating'] as num).toDouble(),
    );
  }
}

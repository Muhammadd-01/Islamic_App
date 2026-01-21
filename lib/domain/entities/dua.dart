class Dua {
  final String id;
  final String arabic;
  final String translation;
  final String reference;
  final String audio;

  Dua({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.reference,
    required this.audio,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'].toString(),
      arabic: json['arabic'],
      translation: json['translation'],
      reference: json['reference'],
      audio: json['audio'],
    );
  }
}

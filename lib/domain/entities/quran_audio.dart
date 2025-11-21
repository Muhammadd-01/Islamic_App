class Reciter {
  final String id;
  final String name;
  final String language;
  final String baseUrl;

  Reciter({
    required this.id,
    required this.name,
    required this.language,
    required this.baseUrl,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'],
      name: json['name'],
      language: json['language'],
      baseUrl: json['baseUrl'],
    );
  }
}

class AyahAudio {
  final int id;
  final String url;

  AyahAudio({required this.id, required this.url});

  factory AyahAudio.fromJson(Map<String, dynamic> json) {
    return AyahAudio(id: json['id'], url: json['url']);
  }
}

class SurahAudio {
  final String surahId;
  final String surahName;
  final List<AyahAudio> ayahs;

  SurahAudio({
    required this.surahId,
    required this.surahName,
    required this.ayahs,
  });

  factory SurahAudio.fromJson(String surahId, Map<String, dynamic> json) {
    return SurahAudio(
      surahId: surahId,
      surahName: json['surah'],
      ayahs: (json['ayahs'] as List).map((e) => AyahAudio.fromJson(e)).toList(),
    );
  }
}

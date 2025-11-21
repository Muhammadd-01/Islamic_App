import 'dart:math';

class MockApiService {
  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
  }

  // Mock Q&A
  Future<Map<String, dynamic>> getAnswer(String question) async {
    await _delay();
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'question': question,
      'answer':
          'This is a mock answer for: "$question". In a real app, this would come from an AI model.',
      'source': 'Mock AI',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Mock Prayer Times
  Future<Map<String, dynamic>> getPrayerTimes(double lat, double long) async {
    await _delay();
    return {
      'fajr': '05:30',
      'dhuhr': '12:30',
      'asr': '15:45',
      'maghrib': '18:15',
      'isha': '19:45',
      'location': 'Mock Location',
      'date': DateTime.now().toIso8601String(),
    };
  }

  // Mock Articles
  Future<List<Map<String, dynamic>>> getArticles() async {
    await _delay();
    return List.generate(
      5,
      (index) => {
        'id': 'article_$index',
        'title': 'Islamic Article ${index + 1}',
        'summary':
            'This is a summary of the article. It contains beneficial knowledge.',
        'content': 'Full content of the article goes here...',
        'imageUrl': 'https://via.placeholder.com/300',
        'category': 'General',
      },
    );
  }

  // Mock Quran Surahs
  Future<List<Map<String, dynamic>>> getSurahs() async {
    await _delay();
    return [
      {
        "number": 1,
        "name": "سورة الفاتحة",
        "englishName": "Al-Fatiha",
        "englishNameTranslation": "The Opening",
        "numberOfAyahs": 7,
        "revelationType": "Meccan",
      },
      {
        "number": 2,
        "name": "سورة البقرة",
        "englishName": "Al-Baqarah",
        "englishNameTranslation": "The Cow",
        "numberOfAyahs": 286,
        "revelationType": "Medinan",
      },
      {
        "number": 3,
        "name": "سورة آل عمران",
        "englishName": "Al-Imran",
        "englishNameTranslation": "The Family of Imran",
        "numberOfAyahs": 200,
        "revelationType": "Medinan",
      },
      {
        "number": 4,
        "name": "سورة النساء",
        "englishName": "An-Nisa",
        "englishNameTranslation": "The Women",
        "numberOfAyahs": 176,
        "revelationType": "Medinan",
      },
      {
        "number": 36,
        "name": "سورة يس",
        "englishName": "Ya-Sin",
        "englishNameTranslation": "Ya Sin",
        "numberOfAyahs": 83,
        "revelationType": "Meccan",
      },
      {
        "number": 67,
        "name": "سورة الملك",
        "englishName": "Al-Mulk",
        "englishNameTranslation": "The Sovereignty",
        "numberOfAyahs": 30,
        "revelationType": "Meccan",
      },
    ];
  }
}

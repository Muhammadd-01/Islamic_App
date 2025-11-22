class IslamicEventService {
  // static const String _baseUrl = 'http://api.aladhan.com/v1'; // Unused for now

  Future<List<dynamic>> getSpecialDays() async {
    // final year = DateTime.now().year; // Unused for now
    // Aladhan doesn't have a direct "special days" endpoint that lists all for the year easily in one go without complex parsing.
    // However, we can fetch the calendar and filter for special days or use a known list of Hijri dates.
    // For this implementation, we will return a curated list of major events with their Hijri dates,
    // and then use the Aladhan Calendar API to find the corresponding Gregorian date if needed.

    // Mocking the "Service" response for major events as a reliable fallback
    return [
      {
        "title": "Ramadan Start",
        "hijri": "1-9",
        "description": "First day of fasting",
      },
      {
        "title": "Eid al-Fitr",
        "hijri": "1-10",
        "description": "Festival of Breaking the Fast",
      },
      {
        "title": "Hajj Start",
        "hijri": "8-12",
        "description": "Annual Islamic Pilgrimage",
      },
      {
        "title": "Day of Arafah",
        "hijri": "9-12",
        "description": "Key day of Hajj",
      },
      {
        "title": "Eid al-Adha",
        "hijri": "10-12",
        "description": "Festival of Sacrifice",
      },
      {
        "title": "Islamic New Year",
        "hijri": "1-1",
        "description": "1st Muharram",
      },
      {"title": "Ashura", "hijri": "10-1", "description": "10th Muharram"},
    ];
  }
}

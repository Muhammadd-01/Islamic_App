class IslamicDate {
  final String currentDate;
  final String hijriDate;
  final String hijriMonth;
  final String hijriYear;
  final String hijriDay;
  final String gregorianDate;
  final List<CalendarEvent> events;

  IslamicDate({
    required this.currentDate,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.hijriDay,
    required this.gregorianDate,
    required this.events,
  });

  factory IslamicDate.fromJson(Map<String, dynamic> json) {
    return IslamicDate(
      currentDate: json['current_date'],
      hijriDate: json['hijri_date'],
      hijriMonth: json['hijri_month'],
      hijriYear: json['hijri_year'],
      hijriDay: json['hijri_day'],
      gregorianDate: json['gregorian_date'],
      events: (json['events'] as List)
          .map((e) => CalendarEvent.fromJson(e))
          .toList(),
    );
  }
}

class CalendarEvent {
  final String date;
  final String title;
  final String description;

  CalendarEvent({
    required this.date,
    required this.title,
    required this.description,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      date: json['date'],
      title: json['title'],
      description: json['description'],
    );
  }
}

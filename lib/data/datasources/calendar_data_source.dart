import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_app/domain/entities/islamic_date.dart';

abstract class CalendarDataSource {
  Future<IslamicDate> getIslamicDate();
}

class LocalCalendarDataSource implements CalendarDataSource {
  @override
  Future<IslamicDate> getIslamicDate() async {
    final String response = await rootBundle.loadString(
      'assets/api/calendar/calendar.json',
    );
    final Map<String, dynamic> data = json.decode(response);
    return IslamicDate.fromJson(data);
  }
}

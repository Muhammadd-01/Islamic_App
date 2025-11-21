import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/datasources/calendar_data_source.dart';
import 'package:islamic_app/data/repositories/calendar_repository_impl.dart';
import 'package:islamic_app/domain/entities/islamic_date.dart';
import 'package:islamic_app/domain/repositories/calendar_repository.dart';

final calendarDataSourceProvider = Provider<CalendarDataSource>((ref) {
  return LocalCalendarDataSource();
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl(ref.watch(calendarDataSourceProvider));
});

final islamicDateProvider = FutureProvider<IslamicDate>((ref) async {
  return ref.watch(calendarRepositoryProvider).getIslamicDate();
});

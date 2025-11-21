import 'package:islamic_app/domain/entities/islamic_date.dart';

abstract class CalendarRepository {
  Future<IslamicDate> getIslamicDate();
}

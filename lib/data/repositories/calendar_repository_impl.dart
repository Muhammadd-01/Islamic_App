import 'package:islamic_app/data/datasources/calendar_data_source.dart';
import 'package:islamic_app/domain/entities/islamic_date.dart';
import 'package:islamic_app/domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarDataSource dataSource;

  CalendarRepositoryImpl(this.dataSource);

  @override
  Future<IslamicDate> getIslamicDate() async {
    return await dataSource.getIslamicDate();
  }
}

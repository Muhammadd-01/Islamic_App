import 'package:adhan/adhan.dart';
import 'package:islamic_app/data/services/aladhan_service.dart';
import 'package:islamic_app/data/services/location_service.dart';

class PrayerRepositoryImpl {
  final AladhanService _service;
  final LocationService _locationService;

  PrayerRepositoryImpl(this._service, this._locationService);

  Future<Map<String, dynamic>> getPrayerTimes() async {
    final position = await _locationService.getCurrentLocation();

    // Default to Mecca if location is not available
    double lat = 21.4225;
    double long = 39.8262;

    if (position != null) {
      lat = position.latitude;
      long = position.longitude;
    }

    return await _service.getPrayerTimes(lat, long);
  }

  Future<Map<String, dynamic>> getHijriDate() async {
    final position = await _locationService.getCurrentLocation();

    // Default to Mecca if location is not available
    double lat = 21.4225;
    double long = 39.8262;

    if (position != null) {
      lat = position.latitude;
      long = position.longitude;
    }

    return await _service.getHijriDate(lat, long);
  }

  Future<double> getQiblaDirection() async {
    final position = await _locationService.getCurrentLocation();

    if (position != null) {
      final coordinates = Coordinates(position.latitude, position.longitude);
      return Qibla(coordinates).direction;
    }

    // Default to a placeholder if no location, though Qibla needs location.
    // 0.0 or error might be better, but let's stick to a safe default for now or throw.
    return 0.0;
  }

  Future<List<dynamic>> getMonthlyPrayerTimes() async {
    // Placeholder for monthly times
    return [];
  }
}

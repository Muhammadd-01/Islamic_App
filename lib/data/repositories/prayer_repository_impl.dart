import 'package:islamic_app/data/services/aladhan_service.dart';

class PrayerRepositoryImpl {
  final AladhanService _service;

  PrayerRepositoryImpl(this._service);

  Future<Map<String, dynamic>> getPrayerTimes() async {
    // Mock location for now (Mecca)
    // In a real app, we would use Geolocator to get user's location
    const double lat = 21.4225;
    const double long = 39.8262;
    return await _service.getPrayerTimes(lat, long);
  }

  Future<Map<String, dynamic>> getHijriDate() async {
    const double lat = 21.4225;
    const double long = 39.8262;
    return await _service.getHijriDate(lat, long);
  }
}

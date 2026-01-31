import 'package:adhan/adhan.dart';
import 'package:islamic_app/data/services/aladhan_service.dart';
import 'package:islamic_app/data/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

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
    try {
      // Use highest accuracy for Qibla
      final position = await _locationService.getCurrentLocation(
        accuracy: LocationAccuracy.best,
        timeout: const Duration(seconds: 15),
      );

      if (position != null) {
        final coordinates = Coordinates(position.latitude, position.longitude);
        final qibla = Qibla(coordinates);
        print(
          'Qibla Direction calculated: ${qibla.direction} for lat: ${position.latitude}, long: ${position.longitude}',
        );
        return qibla.direction;
      }

      print('Qibla Direction: Location not available, returning 0.0');
      return 0.0;
    } catch (e) {
      print('Error calculating Qibla direction: $e');
      return 0.0;
    }
  }

  Future<List<dynamic>> getMonthlyPrayerTimes() async {
    // Placeholder for monthly times
    return [];
  }
}

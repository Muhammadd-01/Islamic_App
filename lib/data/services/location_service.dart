import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location with permission handling
  /// Returns null if permission denied or service disabled
  /// Get current location with permission handling and accuracy control
  Future<Position?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      // Try to get current position with timeout
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: timeout,
        );
      } catch (e) {
        print(
          'Error getting precise position: $e. Falling back to last known.',
        );
        return await Geolocator.getLastKnownPosition();
      }
    } catch (e) {
      print('Error in location service: $e');
      return null;
    }
  }

  /// Get location as formatted string (House #, Street, Sector, City, Country)
  Future<String> getLocationString() async {
    final position = await getCurrentLocation();
    if (position == null) {
      return 'Location not available';
    }

    // 1. Try native geocoding first (with a failsafe)
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = place.name ?? '';
        final street = place.street ?? '';
        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? '';
        final country = place.country ?? '';

        String streetLine = name;
        if (street.isNotEmpty && street != name) {
          streetLine = street;
        }

        // Return if we got meaningful data
        if (streetLine.isNotEmpty || subLocality.isNotEmpty) {
          List<String> parts = [streetLine, subLocality, locality, country];
          final distinctParts = <String>[];
          for (var part in parts) {
            if (part.isNotEmpty && !distinctParts.contains(part)) {
              distinctParts.add(part);
            }
          }
          if (distinctParts.isNotEmpty) return distinctParts.join(', ');
        }
      }
    } catch (e) {
      print('Native geocoding failed/timed out: $e');
    }

    // 2. Robust Fallback to Nominatim (OpenStreetMap)
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1',
      );

      final response = await http
          .get(
            url,
            headers: {'User-Agent': 'IslamicApp/1.0', 'Accept-Language': 'en'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          // Precise mapping for "House No, Street, Sector/Area"
          final house =
              address['house_number'] ??
              address['house_name'] ??
              address['building'] ??
              '';
          final road = address['road'] ?? address['pedestrian'] ?? '';

          // Sector/Area mapping
          final sectorArea =
              address['neighbourhood'] ??
              address['suburb'] ??
              address['quarter'] ??
              address['residential'] ??
              address['city_district'] ??
              address['sector'] ??
              '';

          final city =
              address['city'] ?? address['town'] ?? address['village'] ?? '';
          final country = address['country'] ?? '';

          String streetPart = road;
          if (house.isNotEmpty) {
            streetPart = road.isNotEmpty
                ? 'House $house, $road'
                : 'House $house';
          }

          final parts = [streetPart, sectorArea, city, country]
              .where((p) => p.toString().trim().isNotEmpty)
              .map((p) => p.toString().trim())
              .toList();

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
      }
    } catch (e) {
      print('Nominatim fallback failed: $e');
    }

    // 3. Absolute last resort: Formatted coordinates
    return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Open app settings for location permission
  Future<void> openLocationSettings() async {
    await openAppSettings();
  }
}

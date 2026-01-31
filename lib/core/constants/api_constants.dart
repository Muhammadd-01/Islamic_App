import 'package:flutter/foundation.dart';

class ApiConstants {
  /// The default fallback URL.
  static const String defaultBaseUrl = kDebugMode
      ? 'http://localhost:5000/api'
      : 'https://your-production-url.com/api';

  /// Construct endpoints using the provided dynamic base URL
  static String getBookingsUrl(String baseUrl) => '$baseUrl/bookings';
  static String getInspirationUrl(String baseUrl) => '$baseUrl/inspiration';
  static String getDailyInspirationUrl(String baseUrl) =>
      '$baseUrl/daily-inspirations/today';
}

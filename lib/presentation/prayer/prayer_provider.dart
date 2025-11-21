import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/providers/api_provider.dart';

final prayerTimesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(mockApiServiceProvider);
  // Mock location
  return api.getPrayerTimes(0, 0);
});

final nextPrayerProvider = StreamProvider<String>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    // Logic to calculate next prayer would go here
    // For now, just return a mock countdown
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 18, 15); // Maghrib mock
    if (now.isAfter(target)) {
      return "Next Prayer: Isha";
    }
    final diff = target.difference(now);
    return "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
  });
});

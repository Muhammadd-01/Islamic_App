import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/services/location_service.dart';
import 'package:islamic_app/data/services/aladhan_service.dart';
import 'package:islamic_app/data/repositories/prayer_repository_impl.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final prayerRepositoryProvider = Provider<PrayerRepositoryImpl>((ref) {
  return PrayerRepositoryImpl(
    AladhanService(),
    ref.read(locationServiceProvider),
  );
});

final prayerTimesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(prayerRepositoryProvider);
  return repository.getPrayerTimes();
});

final qiblaDirectionProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(prayerRepositoryProvider);
  return repository.getQiblaDirection();
});

final hijriDateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(prayerRepositoryProvider);
  return repository.getHijriDate();
});

final nextPrayerProvider = StreamProvider<String>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    // In a real app, we would parse the actual prayer times from the provider
    // and calculate the difference. For now, we'll keep the mock countdown
    // but it's ready to be connected to the real data.
    final now = DateTime.now();
    final target = DateTime(
      now.year,
      now.month,
      now.day,
      18,
      15,
    ); // Maghrib mock
    if (now.isAfter(target)) {
      return "Next Prayer: Isha";
    }
    final diff = target.difference(now);
    return "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
  });
});

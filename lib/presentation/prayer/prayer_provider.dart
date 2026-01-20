import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamic_app/data/services/location_service.dart';
import 'package:islamic_app/data/services/aladhan_service.dart';
import 'package:islamic_app/data/repositories/prayer_repository_impl.dart';

/// Provider for today's prayer tracking data from Firestore
final todayPrayerTrackingProvider = StreamProvider<Map<String, dynamic>?>((
  ref,
) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  // Get today's date as document ID
  final today = DateTime.now();
  final dateId =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('prayertracking')
      .doc(dateId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        final data = doc.data() ?? {};

        // Count completed prayers
        int completedCount = 0;
        final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
        for (final prayer in prayers) {
          if (data[prayer] == true) completedCount++;
        }

        return {...data, 'completedCount': completedCount};
      });
});

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

/// Cached prayer times for countdown calculation
class PrayerTimeCache {
  static Map<String, DateTime>? _todayPrayerTimes;
  static DateTime? _cacheDate;

  static void setPrayerTimes(Map<String, dynamic> timings) {
    final now = DateTime.now();
    _cacheDate = now;
    _todayPrayerTimes = {};

    // Parse prayer times from API response
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final prayer in prayers) {
      final timeStr = timings[prayer] as String?;
      if (timeStr != null) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1].split(' ')[0]) ?? 0;
          _todayPrayerTimes![prayer] = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );
        }
      }
    }
  }

  static Map<String, DateTime>? get prayerTimes {
    final now = DateTime.now();
    if (_cacheDate != null &&
        _cacheDate!.day == now.day &&
        _cacheDate!.month == now.month &&
        _todayPrayerTimes != null) {
      return _todayPrayerTimes;
    }
    return null;
  }
}

/// Next prayer name provider
final nextPrayerNameProvider = Provider<String>((ref) {
  final prayerTimes = PrayerTimeCache.prayerTimes;
  if (prayerTimes == null) return 'Loading...';

  final now = DateTime.now();
  final orderedPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  for (final prayer in orderedPrayers) {
    final prayerTime = prayerTimes[prayer];
    if (prayerTime != null && prayerTime.isAfter(now)) {
      return prayer;
    }
  }

  // All prayers passed, next is tomorrow's Fajr
  return 'Fajr';
});

/// Stream provider for real-time countdown
final nextPrayerProvider = StreamProvider<String>((ref) {
  final prayerTimesAsync = ref.watch(prayerTimesProvider);

  return Stream.periodic(const Duration(seconds: 1), (_) {
    final now = DateTime.now();

    // Try to get cached prayer times
    var prayerTimes = PrayerTimeCache.prayerTimes;

    // If no cache, try to set from provider data
    if (prayerTimes == null) {
      prayerTimesAsync.whenData((data) {
        final timings = data['timings'] as Map<String, dynamic>?;
        if (timings != null) {
          PrayerTimeCache.setPrayerTimes(timings);
        }
      });
      prayerTimes = PrayerTimeCache.prayerTimes;
    }

    if (prayerTimes == null) {
      return '--:--:--';
    }

    // Find next prayer time
    DateTime? nextPrayerTime;
    final orderedPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (final prayer in orderedPrayers) {
      final prayerTime = prayerTimes[prayer];
      if (prayerTime != null && prayerTime.isAfter(now)) {
        nextPrayerTime = prayerTime;
        break;
      }
    }

    // If all prayers have passed, calculate time to tomorrow's Fajr
    if (nextPrayerTime == null) {
      final fajr = prayerTimes['Fajr'];
      if (fajr != null) {
        nextPrayerTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          fajr.hour,
          fajr.minute,
        );
      }
    }

    if (nextPrayerTime == null) {
      return '--:--:--';
    }

    final diff = nextPrayerTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  });
});

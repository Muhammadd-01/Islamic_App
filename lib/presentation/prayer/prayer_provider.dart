import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/repositories/prayer_repository_impl.dart';
import 'package:islamic_app/data/services/location_service.dart';
import 'package:islamic_app/data/services/aladhan_service.dart';
import 'package:intl/intl.dart';

// todayPrayerTrackingProvider is now in prayer_tracker_provider.dart

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
    final prayers = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
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

/// Current prayer name provider
final currentPrayerNameProvider = Provider<String>((ref) {
  final prayerTimes = PrayerTimeCache.prayerTimes;
  if (prayerTimes == null) return '...';

  final now = DateTime.now();
  final ordered = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  // Special case: before Fajr
  final fajr = prayerTimes['Fajr'];
  if (fajr != null && now.isBefore(fajr)) return 'Isha';

  for (int i = 0; i < ordered.length; i++) {
    final start = prayerTimes[ordered[i]];
    final next = i < ordered.length - 1 ? prayerTimes[ordered[i + 1]] : null;

    if (start != null && now.isAfter(start)) {
      if (next == null || now.isBefore(next)) {
        return ordered[i] == 'Sunrise' ? 'Ishraq' : ordered[i];
      }
    }
  }

  return 'Isha';
});

/// Comprehensive prayer display info provider
final prayerDisplayInfoProvider = StreamProvider<Map<String, String>>((ref) {
  final prayerTimesAsync = ref.watch(prayerTimesProvider);

  return Stream.periodic(const Duration(seconds: 1), (_) {
    final now = DateTime.now();
    var prayerTimes = PrayerTimeCache.prayerTimes;

    if (prayerTimes == null) {
      prayerTimesAsync.whenData((data) {
        PrayerTimeCache.setPrayerTimes(data);
      });
      prayerTimes = PrayerTimeCache.prayerTimes;
    }

    if (prayerTimes == null) {
      return {
        'currentName': '...',
        'currentStartTime': '--:--',
        'currentRemaining': '--:--:--',
        'nextName': '...',
        'nextStartTime': '--:--',
      };
    }

    final allEvents = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final obligatory = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    String currentName = 'Isha';
    DateTime? currentStartTime;
    DateTime? currentEndsAt;

    String nextName = 'Fajr';
    DateTime? nextStartTime;

    // Determine Current Prayer and when it started
    for (int i = 0; i < allEvents.length; i++) {
      final event = allEvents[i];
      final time = prayerTimes[event];
      if (time != null && now.isAfter(time)) {
        currentName = event == 'Sunrise' ? 'Ishraq' : event;
        currentStartTime = time;
      }
    }

    // Special case for pre-fajr
    final fajrToday = prayerTimes['Fajr'];
    if (fajrToday != null && now.isBefore(fajrToday)) {
      currentName = 'Isha';
      // For display we use today's Isha time
      currentStartTime = prayerTimes['Isha'];
    }

    // Determine when current ends (next event limit)
    for (final event in allEvents) {
      final time = prayerTimes[event];
      if (time != null && time.isAfter(now)) {
        currentEndsAt = time;
        break;
      }
    }
    if (currentEndsAt == null && fajrToday != null) {
      currentEndsAt = DateTime(
        now.year,
        now.month,
        now.day + 1,
        fajrToday.hour,
        fajrToday.minute,
      );
    }

    // Determine Next Obligatory Prayer and its exact time
    for (final prayer in obligatory) {
      final time = prayerTimes[prayer];
      if (time != null && time.isAfter(now)) {
        nextName = prayer;
        nextStartTime = time;
        break;
      }
    }
    if (nextStartTime == null && fajrToday != null) {
      nextName = 'Fajr';
      nextStartTime = DateTime(
        now.year,
        now.month,
        now.day + 1,
        fajrToday.hour,
        fajrToday.minute,
      );
    }

    String formatAMPM(DateTime? dt) {
      if (dt == null) return '--:--';
      return DateFormat('h:mm a').format(dt);
    }

    String formatRemaining(DateTime? target) {
      if (target == null) return '--:--:--';
      final diff = target.difference(now);
      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }

    return {
      'currentName': currentName,
      'currentStartTime': formatAMPM(currentStartTime),
      'currentRemaining': formatRemaining(currentEndsAt),
      'nextName': nextName,
      'nextStartTime': formatAMPM(nextStartTime),
    };
  });
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
        PrayerTimeCache.setPrayerTimes(data);
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

/// Prayer-based greeting provider
final greetingProvider = Provider<String>((ref) {
  final prayerTimes = PrayerTimeCache.prayerTimes;
  final now = DateTime.now();
  final hour = now.hour;

  if (prayerTimes == null) {
    // Fallback to standard hour-based greetings if prayer times aren't loaded
    if (hour < 12) return 'good_morning';
    if (hour < 17) return 'good_afternoon';
    if (hour < 21) return 'good_evening';
    return 'good_night';
  }

  final fajr = prayerTimes['Fajr'];
  final asr = prayerTimes['Asr'];
  final maghrib = prayerTimes['Maghrib'];

  // 1. After Fajr until 12:00 PM -> Good Morning
  final noon = DateTime(now.year, now.month, now.day, 12, 0);
  if (fajr != null && now.isAfter(fajr) && now.isBefore(noon)) {
    return 'good_morning';
  }

  // 2. After 12:00 PM until Asr -> Good Afternoon
  if (now.isAfter(noon) && (asr == null || now.isBefore(asr))) {
    return 'good_afternoon';
  }

  // 3. After Asr until Maghrib -> Good Evening
  if (asr != null &&
      now.isAfter(asr) &&
      (maghrib == null || now.isBefore(maghrib))) {
    return 'good_evening';
  }

  // 4. After Maghrib until Fajr (next day) -> Good Night
  return 'good_night';
});

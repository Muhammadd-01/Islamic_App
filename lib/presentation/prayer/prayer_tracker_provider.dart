import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/repositories/prayer_tracker_repository.dart';

import 'package:islamic_app/presentation/auth/auth_provider.dart';

/// Repository provider
final prayerTrackerRepositoryProvider = Provider<PrayerTrackerRepository>((
  ref,
) {
  return PrayerTrackerRepository();
});

/// Provider for today's prayer tracking - streams live updates
/// Watching authStateProvider ensures this reloads when user logs in/out
final todayPrayerTrackingProvider = StreamProvider<PrayerTrackingData>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null)
    return Stream.value(PrayerTrackingData(date: ''));

  final repository = ref.watch(prayerTrackerRepositoryProvider);
  return repository.watchTodayTracking();
});

/// Provider for today's completed prayer count
final completedPrayerCountProvider = Provider<AsyncValue<int>>((ref) {
  final tracking = ref.watch(todayPrayerTrackingProvider);
  return tracking.when(
    data: (data) => AsyncValue.data(data.completedCount),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

/// Provider for toggling a prayer's status
final togglePrayerProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(prayerTrackerRepositoryProvider);
  return (String prayerName) => repository.togglePrayer(prayerName);
});

/// Provider for checking if a specific prayer is complete
final isPrayerCompleteProvider = Provider.family<bool, String>((
  ref,
  prayerName,
) {
  final tracking = ref.watch(todayPrayerTrackingProvider);
  return tracking.when(
    data: (data) {
      switch (prayerName.toLowerCase()) {
        case 'fajr':
          return data.fajr;
        case 'dhuhr':
        case 'jummah':
          return data.dhuhr;
        case 'asr':
          return data.asr;
        case 'maghrib':
          return data.maghrib;
        case 'isha':
          return data.isha;
        default:
          return false;
      }
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for monthly prayer history
final monthlyPrayerHistoryProvider =
    FutureProvider.family<List<PrayerTrackingData>, ({int year, int month})>((
      ref,
      params,
    ) {
      final repository = ref.watch(prayerTrackerRepositoryProvider);
      return repository.getMonthlyHistory(params.year, params.month);
    });

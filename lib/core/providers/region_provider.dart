import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/providers/user_provider.dart';

final regionsStreamProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('regions')
      .orderBy('name')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => doc.data()['name'] as String)
            .toList();
      });
});

/// Notifier for the TENTATIVE selection in a dropdown (view-only)
class SelectedRegionNotifier extends Notifier<String> {
  String? _lastOfficialRegion;

  @override
  String build() {
    final profileRegion =
        ref.watch(userProfileProvider.select((p) => p.value?.region)) ??
        'Global';

    // If the profile region officially changed (e.g. after a save),
    // we should update our current view to match it.
    if (_lastOfficialRegion != profileRegion) {
      _lastOfficialRegion = profileRegion;
      return profileRegion;
    }

    // Otherwise, maintain the user's tentative selection
    return state;
  }

  void setRegion(String region) {
    state = region;
  }
}

final selectedRegionProvider = NotifierProvider<SelectedRegionNotifier, String>(
  SelectedRegionNotifier.new,
);

/// A ticker provider that emits a value every second to trigger UI refreshes.
final _countdownTickerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now().second,
  );
});

/// Provider to check if the user is currently allowed to change their region
final regionLockProvider = Provider<({bool canChange, int remainingDays})>((
  ref,
) {
  // Watch the ticker to trigger periodic refreshes
  ref.watch(_countdownTickerProvider);

  final userAsync = ref.watch(userProfileProvider);

  // If still loading, default to allowed (prevents UI flicker)
  if (userAsync.isLoading) return (canChange: true, remainingDays: 0);

  final user = userAsync.value;
  if (user == null) return (canChange: false, remainingDays: 0);

  // EXCEPTION: If the user's current region is 'Global' or null,
  // allow them to change it once, even if they have a lastUpdate timestamp.
  // This fixes the bug where new users were auto-locked at creation.
  if (user.region == null || user.region == 'Global') {
    return (canChange: true, remainingDays: 0);
  }

  final lastUpdate = user.lastRegionUpdate;
  if (lastUpdate == null) return (canChange: true, remainingDays: 0);

  final now = DateTime.now();
  final difference = now.difference(lastUpdate).inDays;
  final remaining = 30 - difference;

  return (
    canChange: remaining <= 0,
    remainingDays: remaining > 0 ? remaining : 0,
  );
});

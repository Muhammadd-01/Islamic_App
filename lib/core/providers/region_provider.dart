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

/// Provider to check if the user is currently allowed to change their region
final regionLockProvider = Provider<({bool canChange, int remainingDays})>((
  ref,
) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return (canChange: false, remainingDays: 0);

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

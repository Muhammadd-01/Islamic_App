import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/providers/region_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class TasbeehStats {
  final int totalCount;
  final int dailyCount;
  final int streakCount;
  final DateTime lastUpdated;

  TasbeehStats({
    required this.totalCount,
    required this.dailyCount,
    required this.streakCount,
    required this.lastUpdated,
  });

  factory TasbeehStats.fromMap(Map<String, dynamic> map) {
    return TasbeehStats(
      totalCount: map['totalCount'] ?? 0,
      dailyCount: map['dailyCount'] ?? 0,
      streakCount: map['streakCount'] ?? 0,
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'totalCount': totalCount,
    'dailyCount': dailyCount,
    'streakCount': streakCount,
    'lastUpdated': Timestamp.fromDate(lastUpdated),
  };
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? imageUrl;
  final String? region;
  final int totalCount;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.imageUrl,
    this.region,
    required this.totalCount,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, String id) {
    final img = map['imageUrl'];
    return LeaderboardEntry(
      userId: id,
      userName: map['name'] ?? 'User',
      imageUrl: (img != null && img.toString().isNotEmpty)
          ? img.toString()
          : null,
      region: map['region'],
      totalCount: map['total_tasbeeh_count'] ?? 0,
    );
  }
}

class TasbeehRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth _fbAuth = fb.FirebaseAuth.instance;

  String? get _userId => _fbAuth.currentUser?.uid;

  Future<void> updateCount(int increment) async {
    final uid = _userId;
    if (uid == null) return;

    final userDoc = _firestore.collection('users').doc(uid);
    final statsDoc = _firestore.collection('tasbeeh_stats').doc(uid);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    await _firestore.runTransaction((transaction) async {
      final statsSnapshot = await transaction.get(statsDoc);

      int total = increment;
      int daily = increment;
      int streak = 1;

      if (statsSnapshot.exists) {
        final data = statsSnapshot.data()!;
        final lastUpdate =
            (data['lastUpdated'] as Timestamp?)?.toDate() ??
            DateTime.now().subtract(const Duration(days: 2));
        final lastUpdateDay = DateTime(
          lastUpdate.year,
          lastUpdate.month,
          lastUpdate.day,
        );

        total = (data['totalCount'] ?? 0) + increment;
        streak = data['streakCount'] ?? 0;

        if (lastUpdateDay.isAtSameMomentAs(today)) {
          daily = (data['dailyCount'] ?? 0) + increment;
        } else if (lastUpdateDay.isAtSameMomentAs(yesterday)) {
          daily = increment;
          streak++;
        } else {
          daily = increment;
          streak = 1;
        }
      }

      transaction.set(statsDoc, {
        'totalCount': total,
        'dailyCount': daily,
        'streakCount': streak,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Also update the main user document for easy leaderboard fetching
      // Use set with merge: true to ensure it works even if doc is somehow missing
      transaction.set(userDoc, {
        'total_tasbeeh_count': total,
      }, SetOptions(merge: true));
    });
  }

  Stream<TasbeehStats> getStatsStream() {
    final uid = _userId;
    if (uid == null)
      return Stream.value(
        TasbeehStats(
          totalCount: 0,
          dailyCount: 0,
          streakCount: 0,
          lastUpdated: DateTime.now(),
        ),
      );

    return _firestore.collection('tasbeeh_stats').doc(uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists)
        return TasbeehStats(
          totalCount: 0,
          dailyCount: 0,
          streakCount: 0,
          lastUpdated: DateTime.now(),
        );
      return TasbeehStats.fromMap(snapshot.data()!);
    });
  }

  Stream<List<LeaderboardEntry>> getLeaderboardStream({String? region}) {
    Query query = _firestore.collection('users');

    if (region != null && region != 'Global') {
      query = query.where('region', isEqualTo: region);
    }

    return query
        .orderBy('total_tasbeeh_count', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => LeaderboardEntry.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Stream<List<Map<String, String>>> getAzkarStream() {
    return _firestore.collection('azkar').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // Return default set if collection is empty
        return [
          {
            'name': 'SubhanAllah',
            'arabic': 'سُبْحَانَ اللّٰهِ',
            'meaning': 'Glory be to Allah',
          },
          {
            'name': 'Alhamdulillah',
            'arabic': 'الْحَمْدُ لِلّٰهِ',
            'meaning': 'Praise be to Allah',
          },
          {
            'name': 'Allahu Akbar',
            'arabic': 'اللّٰهُ أَكْبَرُ',
            'meaning': 'Allah is the Greatest',
          },
        ];
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name']?.toString() ?? '',
          'arabic': data['arabic']?.toString() ?? '',
          'meaning': data['meaning']?.toString() ?? '',
        };
      }).toList();
    });
  }
}

final tasbeehRepositoryProvider = Provider((ref) => TasbeehRepository());

final tasbeehStatsProvider = StreamProvider<TasbeehStats>((ref) {
  return ref.watch(tasbeehRepositoryProvider).getStatsStream();
});

final leaderboardProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final region = ref.watch(selectedRegionProvider);
  return ref
      .watch(tasbeehRepositoryProvider)
      .getLeaderboardStream(region: region);
});

final azkarProvider = StreamProvider<List<Map<String, String>>>((ref) {
  return ref.watch(tasbeehRepositoryProvider).getAzkarStream();
});

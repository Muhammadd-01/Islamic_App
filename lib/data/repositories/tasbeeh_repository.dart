import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasbeehStats {
  final int totalCount;
  final int dailyCount;
  final DateTime lastUpdated;

  TasbeehStats({
    required this.totalCount,
    required this.dailyCount,
    required this.lastUpdated,
  });

  factory TasbeehStats.fromMap(Map<String, dynamic> map) {
    return TasbeehStats(
      totalCount: map['totalCount'] ?? 0,
      dailyCount: map['dailyCount'] ?? 0,
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'totalCount': totalCount,
    'dailyCount': dailyCount,
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
    return LeaderboardEntry(
      userId: id,
      userName: map['name'] ?? 'User',
      imageUrl: map['imageUrl'],
      region: map['region'],
      totalCount: map['total_tasbeeh_count'] ?? 0,
    );
  }
}

class TasbeehRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> updateCount(int increment) async {
    final uid = _userId;
    if (uid == null) return;

    final userDoc = _firestore.collection('users').doc(uid);
    final statsDoc = _firestore.collection('tasbeeh_stats').doc(uid);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _firestore.runTransaction((transaction) async {
      final statsSnapshot = await transaction.get(statsDoc);

      int total = increment;
      int daily = increment;

      if (statsSnapshot.exists) {
        final data = statsSnapshot.data()!;
        final lastUpdate = (data['lastUpdated'] as Timestamp).toDate();
        final lastUpdateDay = DateTime(
          lastUpdate.year,
          lastUpdate.month,
          lastUpdate.day,
        );

        total = (data['totalCount'] ?? 0) + increment;

        if (lastUpdateDay.isAtSameMomentAs(today)) {
          daily = (data['dailyCount'] ?? 0) + increment;
        } else {
          daily = increment;
        }
      }

      transaction.set(statsDoc, {
        'totalCount': total,
        'dailyCount': daily,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Also update the main user document for easy leaderboard fetching
      transaction.update(userDoc, {'total_tasbeeh_count': total});
    });
  }

  Stream<TasbeehStats> getStatsStream() {
    final uid = _userId;
    if (uid == null)
      return Stream.value(
        TasbeehStats(totalCount: 0, dailyCount: 0, lastUpdated: DateTime.now()),
      );

    return _firestore.collection('tasbeeh_stats').doc(uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists)
        return TasbeehStats(
          totalCount: 0,
          dailyCount: 0,
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
}

final tasbeehRepositoryProvider = Provider((ref) => TasbeehRepository());

final tasbeehStatsProvider = StreamProvider<TasbeehStats>((ref) {
  return ref.watch(tasbeehRepositoryProvider).getStatsStream();
});

class LeaderboardRegion extends Notifier<String> {
  @override
  String build() => 'Global';

  void update(String value) => state = value;
}

final leaderboardRegionProvider = NotifierProvider<LeaderboardRegion, String>(
  LeaderboardRegion.new,
);

final leaderboardProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final region = ref.watch(leaderboardRegionProvider);
  return ref
      .watch(tasbeehRepositoryProvider)
      .getLeaderboardStream(region: region);
});

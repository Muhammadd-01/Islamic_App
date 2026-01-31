import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for daily prayer tracking
class PrayerTrackingData {
  final String date; // YYYY-MM-DD format
  final bool fajr;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;
  final DateTime? lastUpdated;

  PrayerTrackingData({
    required this.date,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    this.lastUpdated,
  });

  int get completedCount {
    int count = 0;
    if (fajr) count++;
    if (dhuhr) count++;
    if (asr) count++;
    if (maghrib) count++;
    if (isha) count++;
    return count;
  }

  factory PrayerTrackingData.fromMap(Map<String, dynamic> map, String date) {
    return PrayerTrackingData(
      date: date,
      fajr: map['fajr'] ?? false,
      dhuhr: map['dhuhr'] ?? false,
      asr: map['asr'] ?? false,
      maghrib: map['maghrib'] ?? false,
      isha: map['isha'] ?? false,
      lastUpdated: map['last_updated'] != null
          ? (map['last_updated'] is Timestamp
                ? (map['last_updated'] as Timestamp).toDate()
                : DateTime.parse(map['last_updated'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'date': date,
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'last_updated': FieldValue.serverTimestamp(),
    };
  }

  PrayerTrackingData copyWith({
    bool? fajr,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
  }) {
    return PrayerTrackingData(
      date: date,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      lastUpdated: lastUpdated,
    );
  }
}

/// Repository for prayer tracking data in Firebase Firestore
class PrayerTrackerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _collection =>
      _firestore.collection('prayer_tracking');

  /// Get today's date in YYYY-MM-DD format
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get the document ID for a specific date
  String _getDocId(String uid, String date) => '${uid}_$date';

  /// Get today's prayer tracking data
  Future<PrayerTrackingData> getTodayTracking() async {
    final uid = _userId;
    if (uid == null) return PrayerTrackingData(date: _getTodayDate());

    final date = _getTodayDate();
    try {
      final docId = _getDocId(uid, date);
      final doc = await _collection.doc(docId).get();

      if (doc.exists && doc.data() != null) {
        return PrayerTrackingData.fromMap(
          doc.data() as Map<String, dynamic>,
          date,
        );
      }
      return PrayerTrackingData(date: date);
    } catch (e) {
      print('Error getting Firestore tracking: $e');
      return PrayerTrackingData(date: date);
    }
  }

  /// Stream today's prayer tracking data
  Stream<PrayerTrackingData> watchTodayTracking() {
    final uid = _userId;
    final date = _getTodayDate();
    if (uid == null) {
      return Stream.value(PrayerTrackingData(date: date));
    }

    final docId = _getDocId(uid, date);
    return _collection.doc(docId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return PrayerTrackingData.fromMap(
          snapshot.data() as Map<String, dynamic>,
          date,
        );
      }
      return PrayerTrackingData(date: date);
    });
  }

  /// Update a specific prayer completion status
  Future<void> updatePrayerStatus(String prayerName, bool completed) async {
    final uid = _userId;
    if (uid == null) {
      throw Exception('Please sign in to save your prayer progress');
    }

    final date = _getTodayDate();
    final normalizedName = prayerName.toLowerCase() == 'jummah'
        ? 'dhuhr'
        : prayerName.toLowerCase();

    try {
      final docId = _getDocId(uid, date);
      await _collection.doc(docId).set({
        'user_id': uid,
        'date': date,
        normalizedName: completed,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        throw Exception(
          'Permission denied. Please ensure Firestore security rules are updated in Firebase Console.',
        );
      }
      throw Exception('Failed to update prayer in Firestore: $e');
    }
  }

  /// Toggle a prayer's completion status
  Future<void> togglePrayer(String prayerName) async {
    final current = await getTodayTracking();
    bool newValue;
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        newValue = !current.fajr;
        break;
      case 'dhuhr':
      case 'jummah':
        newValue = !current.dhuhr;
        break;
      case 'asr':
        newValue = !current.asr;
        break;
      case 'maghrib':
        newValue = !current.maghrib;
        break;
      case 'isha':
        newValue = !current.isha;
        break;
      default:
        return;
    }
    await updatePrayerStatus(prayerName, newValue);
  }

  /// Get prayer tracking history for a specific month
  Future<List<PrayerTrackingData>> getMonthlyHistory(
    int year,
    int month,
  ) async {
    final uid = _userId;
    if (uid == null) return [];

    final startDate = '${year}-${month.toString().padLeft(2, '0')}-01';
    final endDate = '${year}-${month.toString().padLeft(2, '0')}-31';

    try {
      final querySnapshot = await _collection
          .where('user_id', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PrayerTrackingData.fromMap(data, data['date']);
      }).toList();
    } catch (e) {
      print('Error getting monthly history: $e');
      return [];
    }
  }

  /// Get tracking data for a specific date
  Future<PrayerTrackingData> getTrackingForDate(String date) async {
    final uid = _userId;
    if (uid == null) return PrayerTrackingData(date: date);

    try {
      final docId = _getDocId(uid, date);
      final doc = await _collection.doc(docId).get();

      if (doc.exists && doc.data() != null) {
        return PrayerTrackingData.fromMap(
          doc.data() as Map<String, dynamic>,
          date,
        );
      }
      return PrayerTrackingData(date: date);
    } catch (e) {
      return PrayerTrackingData(date: date);
    }
  }
}

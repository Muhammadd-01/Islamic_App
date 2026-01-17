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
  final DateTime? createdAt;

  PrayerTrackingData({
    required this.date,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    this.createdAt,
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
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
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
      createdAt: createdAt,
    );
  }
}

/// Repository for prayer tracking data in Firestore
class PrayerTrackerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Get today's date in YYYY-MM-DD format
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get collection reference for user's prayer tracking
  CollectionReference<Map<String, dynamic>> _getCollection() {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('prayerTracking');
  }

  /// Get today's prayer tracking data
  Future<PrayerTrackingData> getTodayTracking() async {
    final date = _getTodayDate();
    try {
      final doc = await _getCollection().doc(date).get();
      if (doc.exists) {
        return PrayerTrackingData.fromMap(doc.data()!, date);
      }
      return PrayerTrackingData(date: date);
    } catch (e) {
      return PrayerTrackingData(date: date);
    }
  }

  /// Stream today's prayer tracking data
  Stream<PrayerTrackingData> watchTodayTracking() {
    final date = _getTodayDate();
    try {
      return _getCollection().doc(date).snapshots().map((doc) {
        if (doc.exists) {
          return PrayerTrackingData.fromMap(doc.data()!, date);
        }
        return PrayerTrackingData(date: date);
      });
    } catch (e) {
      return Stream.value(PrayerTrackingData(date: date));
    }
  }

  /// Update a specific prayer completion status
  Future<void> updatePrayerStatus(String prayerName, bool completed) async {
    final date = _getTodayDate();
    final docRef = _getCollection().doc(date);

    await docRef.set({
      prayerName.toLowerCase(): completed,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = '$year-${month.toString().padLeft(2, '0')}-31';

    try {
      final snapshot = await _getCollection()
          .orderBy(FieldPath.documentId)
          .startAt([startDate])
          .endAt([endDate])
          .get();

      return snapshot.docs.map((doc) {
        return PrayerTrackingData.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get tracking data for a specific date
  Future<PrayerTrackingData> getTrackingForDate(String date) async {
    try {
      final doc = await _getCollection().doc(date).get();
      if (doc.exists) {
        return PrayerTrackingData.fromMap(doc.data()!, date);
      }
      return PrayerTrackingData(date: date);
    } catch (e) {
      return PrayerTrackingData(date: date);
    }
  }
}

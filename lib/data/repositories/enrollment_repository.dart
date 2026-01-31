import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnrollmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> submitEnrollment({
    required String courseId,
    required String courseTitle,
    required String userName,
    required String userEmail,
    required String phone,
    required String comments,
    required String paymentStatus,
    required int age,
    required String qualification,
    String? paymentMethod,
    double? amountPaid,
    String? transactionId,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore.collection('course_enrollments').add({
      'userId': _userId,
      'userEmail': userEmail,
      'userName': userName,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'phone': phone,
      'comments': comments,
      'status': 'pending',
      'paymentStatus': paymentStatus,
      'age': age,
      'qualification': qualification,
      'paymentMethod': paymentMethod,
      'amountPaid': amountPaid,
      'transactionId': transactionId,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchUserEnrollments() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('course_enrollments')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  return EnrollmentRepository();
});

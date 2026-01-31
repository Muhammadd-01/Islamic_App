import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Question model for community Q&A
class Question {
  final String id;
  final String userId;
  final String userName;
  final String question;
  final String? answer;
  final String status; // 'pending' or 'answered'
  final DateTime createdAt;
  final DateTime? answeredAt;

  Question({
    required this.id,
    required this.userId,
    required this.userName,
    required this.question,
    this.answer,
    this.status = 'pending',
    required this.createdAt,
    this.answeredAt,
  });

  factory Question.fromMap(Map<String, dynamic> map, String id) {
    return Question(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      question: map['question'] ?? '',
      answer: map['answer'],
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answeredAt: (map['answeredAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'question': question,
      'answer': answer,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'answeredAt': answeredAt != null ? Timestamp.fromDate(answeredAt!) : null,
    };
  }
}

/// Questions Repository
class QuestionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _questionsCollection =>
      _firestore.collection('questions');

  String? get _userId => _fbAuth.currentUser?.uid;

  String? get _userName => _fbAuth.currentUser?.displayName;

  /// Post a new question
  Future<void> postQuestion(String question) async {
    if (_userId == null) return;

    await _questionsCollection.add({
      'userId': _userId,
      'userName': _userName ?? 'Anonymous',
      'question': question,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all questions stream
  Stream<List<Question>> getQuestionsStream() {
    return _questionsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Question.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Get answered questions for current user
  Stream<List<Question>> getMyAnsweredQuestionsStream() {
    if (_userId == null) return Stream.value([]);

    return _questionsCollection
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: 'answered')
        .orderBy('answeredAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Question.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}

/// Notification model
class AppNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? questionId;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.questionId,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      questionId: map['questionId'],
      read: map['read'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Notifications Repository
class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;

  String? get _userId => _fbAuth.currentUser?.uid;

  /// Get notifications stream for current user
  Stream<List<AppNotification>> getNotificationsStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  /// Get unread count
  Stream<int> getUnreadCountStream() {
    if (_userId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

// Providers
final questionsRepositoryProvider = Provider((ref) => QuestionsRepository());

final questionsStreamProvider = StreamProvider<List<Question>>((ref) {
  final repo = ref.watch(questionsRepositoryProvider);
  return repo.getQuestionsStream();
});

final notificationsRepositoryProvider = Provider(
  (ref) => NotificationsRepository(),
);

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((
  ref,
) {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getNotificationsStream();
});

final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getUnreadCountStream();
});

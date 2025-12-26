import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/repositories/cart_repository.dart';

/// Order model
class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.paymentMethod = 'card',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'items': items.map((i) => i.toMap()).toList(),
    'total': total,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'paymentMethod': paymentMethod,
  };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    items:
        (map['items'] as List<dynamic>?)
            ?.map((i) => CartItem.fromMap(i as Map<String, dynamic>))
            .toList() ??
        [],
    total: (map['total'] ?? 0).toDouble(),
    status: map['status'] ?? 'pending',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    paymentMethod: map['paymentMethod'] ?? 'card',
  );
}

/// Orders Repository
class OrdersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  /// Create a new order
  Future<String?> createOrder({
    required List<CartItem> items,
    required double total,
    String paymentMethod = 'card',
  }) async {
    if (_userId == null) return null;

    final docRef = _ordersCollection.doc();
    final order = Order(
      id: docRef.id,
      userId: _userId!,
      items: items,
      total: total,
      status: 'completed',
      createdAt: DateTime.now(),
      paymentMethod: paymentMethod,
    );

    await docRef.set(order.toMap());
    return docRef.id;
  }

  /// Get user's orders stream
  Stream<List<Order>> getOrdersStream() {
    if (_userId == null) return Stream.value([]);

    return _ordersCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromMap(doc.data())).toList(),
        );
  }

  /// Get user's orders (one-time fetch)
  Future<List<Order>> getOrders() async {
    if (_userId == null) return [];

    final snapshot = await _ordersCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Order.fromMap(doc.data())).toList();
  }

  /// Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (!doc.exists) return null;
    return Order.fromMap(doc.data()!);
  }
}

// Riverpod Providers
final ordersRepositoryProvider = Provider((ref) => OrdersRepository());

final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.getOrdersStream();
});

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cart item model
class CartItem {
  final String bookId;
  final String title;
  final String author;
  final double price;
  final String coverUrl;
  final int quantity;

  CartItem({
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.coverUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
    'bookId': bookId,
    'title': title,
    'author': author,
    'price': price,
    'coverUrl': coverUrl,
    'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    bookId: map['bookId'] ?? '',
    title: map['title'] ?? '',
    author: map['author'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    coverUrl: map['coverUrl'] ?? '',
    quantity: map['quantity'] ?? 1,
  );

  CartItem copyWith({int? quantity}) => CartItem(
    bookId: bookId,
    title: title,
    author: author,
    price: price,
    coverUrl: coverUrl,
    quantity: quantity ?? this.quantity,
  );
}

/// Cart Repository for Firestore operations
class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _cartDoc {
    if (_userId == null) return null;
    return _firestore.collection('carts').doc(_userId);
  }

  /// Get cart items stream
  Stream<List<CartItem>> getCartStream() {
    if (_cartDoc == null) return Stream.value([]);

    return _cartDoc!.snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data();
      if (data == null || data['items'] == null) return [];

      final items = data['items'] as List<dynamic>;
      return items
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get cart items (one-time fetch)
  Future<List<CartItem>> getCartItems() async {
    if (_cartDoc == null) return [];

    final snapshot = await _cartDoc!.get();
    if (!snapshot.exists) return [];

    final data = snapshot.data();
    if (data == null || data['items'] == null) return [];

    final items = data['items'] as List<dynamic>;
    return items
        .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Add item to cart
  Future<void> addToCart(CartItem item) async {
    if (_cartDoc == null) return;

    final items = await getCartItems();
    final existingIndex = items.indexWhere((i) => i.bookId == item.bookId);

    if (existingIndex >= 0) {
      // Update quantity if already exists
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + 1,
      );
    } else {
      items.add(item);
    }

    await _cartDoc!.set({
      'items': items.map((i) => i.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove item from cart
  Future<void> removeFromCart(String bookId) async {
    if (_cartDoc == null) return;

    final items = await getCartItems();
    items.removeWhere((item) => item.bookId == bookId);

    await _cartDoc!.set({
      'items': items.map((i) => i.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update item quantity
  Future<void> updateQuantity(String bookId, int quantity) async {
    if (_cartDoc == null) return;
    if (quantity <= 0) {
      await removeFromCart(bookId);
      return;
    }

    final items = await getCartItems();
    final index = items.indexWhere((i) => i.bookId == bookId);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
      await _cartDoc!.set({
        'items': items.map((i) => i.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    if (_cartDoc == null) return;
    await _cartDoc!.delete();
  }

  /// Get cart total
  Future<double> getCartTotal() async {
    final items = await getCartItems();
    return items.fold<double>(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );
  }
}

// Riverpod Providers
final cartRepositoryProvider = Provider((ref) => CartRepository());

final cartStreamProvider = StreamProvider<List<CartItem>>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return repo.getCartStream();
});

final cartItemCountProvider = Provider<int>((ref) {
  final cartAsync = ref.watch(cartStreamProvider);
  return cartAsync.maybeWhen(
    data: (items) => items.fold(0, (total, item) => total + item.quantity),
    orElse: () => 0,
  );
});

final cartTotalProvider = FutureProvider<double>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return repo.getCartTotal();
});

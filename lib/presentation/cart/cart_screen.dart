import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/data/repositories/cart_repository.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: true,
        actions: [
          cartAsync.maybeWhen(
            data: (items) => items.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Cart'),
                          content: const Text('Remove all items from cart?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(cartRepositoryProvider).clearCart();
                        if (context.mounted) {
                          AppSnackbar.showInfo(context, 'Cart cleared');
                        }
                      }
                    },
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: cartAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/library'),
                    child: const Text('Browse Books'),
                  ),
                ],
              ).animate().fade().scale(),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemCard(item: item, ref: ref)
                        .animate()
                        .fade(delay: (50 * index).ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
              _CartSummary(items: items),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final WidgetRef ref;

  const _CartItemCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Book cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.coverUrl,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.book),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.author,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 20,
                      onPressed: () {
                        ref
                            .read(cartRepositoryProvider)
                            .updateQuantity(item.bookId, item.quantity - 1);
                      },
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 20,
                      onPressed: () {
                        ref
                            .read(cartRepositoryProvider)
                            .updateQuantity(item.bookId, item.quantity + 1);
                      },
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(cartRepositoryProvider)
                        .removeFromCart(item.bookId);
                    AppSnackbar.showInfo(context, 'Removed from cart');
                  },
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final List<CartItem> items;

  const _CartSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0.1; // 10% tax
    final total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: TextStyle(color: Colors.grey[600])),
                Text('\$${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax (10%)', style: TextStyle(color: Colors.grey[600])),
                Text('\$${tax.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

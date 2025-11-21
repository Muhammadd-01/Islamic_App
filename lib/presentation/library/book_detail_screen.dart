import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/domain/entities/book.dart';
import 'package:islamic_app/data/repositories/bookmark_repository.dart';
import 'package:islamic_app/domain/entities/bookmark.dart';

class BookDetailScreen extends ConsumerWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final bookmarksAsync = ref.watch(bookmarksProvider);
              final isBookmarked = bookmarksAsync.maybeWhen(
                data: (bookmarks) =>
                    bookmarks.any((b) => b.id == book.id && b.type == 'book'),
                orElse: () => false,
              );

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.primary : null,
                ),
                onPressed: () async {
                  final repo = ref.read(bookmarkRepositoryProvider);
                  if (isBookmarked) {
                    await repo.removeBookmark(book.id, 'book');
                  } else {
                    await repo.addBookmark(
                      Bookmark(
                        id: book.id,
                        type: 'book',
                        title: book.title,
                        subtitle: book.author,
                        route: '/library/${book.id}',
                        timestamp: DateTime.now(),
                      ),
                    );
                  }
                  // ignore: unused_result
                  ref.refresh(bookmarksProvider);
                },
              );
            },
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'book_${book.id}',
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    book.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 160,
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 50),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'by ${book.author}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoChip(
                  icon: Icons.star,
                  label: book.rating.toString(),
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                _InfoChip(
                  icon: Icons.language,
                  label: 'English',
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _InfoChip(
                  icon: Icons.pages,
                  label: '250 Pages',
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleAction(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  book.isFree ? 'READ NOW' : 'BUY FOR \$${book.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fade().scale(),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              book.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context) {
    if (book.isFree) {
      context.push('/book-reader', extra: book);
    } else {
      // Show payment dialog (mock)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Purchase Book'),
          content: Text(
            'Confirm purchase of "${book.title}" for \$${book.price}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Purchase successful! Added to library.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

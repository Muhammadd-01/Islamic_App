import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/data/repositories/bookmark_repository.dart';
import 'package:islamic_app/domain/entities/bookmark.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedType,
            onSelected: (value) {
              setState(() => _selectedType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'quran', child: Text('Quran')),
              const PopupMenuItem(value: 'hadith', child: Text('Hadith')),
              const PopupMenuItem(value: 'dua', child: Text('Dua')),
              const PopupMenuItem(value: 'qa', child: Text('Q&A')),
              const PopupMenuItem(value: 'book', child: Text('Books')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          final filteredBookmarks = _selectedType == 'all'
              ? bookmarks
              : bookmarks.where((b) => b.type == _selectedType).toList();

          if (filteredBookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedType == 'all'
                        ? 'No bookmarks yet'
                        : 'No ${_selectedType} bookmarks',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start bookmarking your favorite content',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredBookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = filteredBookmarks[index];
              return _BookmarkCard(bookmark: bookmark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading bookmarks: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkCard extends ConsumerWidget {
  final Bookmark bookmark;

  const _BookmarkCard({required this.bookmark});

  IconData _getTypeIcon() {
    switch (bookmark.type) {
      case 'quran':
        return Icons.menu_book;
      case 'hadith':
        return Icons.auto_stories;
      case 'dua':
        return Icons.favorite;
      case 'qa':
        return Icons.question_answer;
      case 'book':
        return Icons.library_books;
      default:
        return Icons.bookmark;
    }
  }

  Color _getTypeColor() {
    switch (bookmark.type) {
      case 'quran':
        return Colors.green;
      case 'hadith':
        return Colors.blue;
      case 'dua':
        return Colors.purple;
      case 'qa':
        return Colors.orange;
      case 'book':
        return Colors.brown;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (bookmark.route.isNotEmpty) {
            context.push(bookmark.route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (bookmark.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        bookmark.subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (bookmark.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        bookmark.content,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(bookmark.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remove Bookmark'),
                      content: const Text(
                        'Are you sure you want to remove this bookmark?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final repo = ref.read(bookmarkRepositoryProvider);
                    await repo.removeBookmark(bookmark.id, bookmark.type);
                    if (context.mounted) {
                      AppSnackbar.showInfo(context, 'Bookmark removed');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

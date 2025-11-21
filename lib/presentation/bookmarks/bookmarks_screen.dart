import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/data/repositories/bookmark_repository.dart';
import 'package:islamic_app/domain/entities/bookmark.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Quran'),
            Tab(text: 'Hadith'),
            Tab(text: 'Dua'),
            Tab(text: 'Q&A'),
          ],
        ),
      ),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookmarkList(bookmarks, 'quran'),
              _buildBookmarkList(bookmarks, 'hadith'),
              _buildBookmarkList(bookmarks, 'dua'),
              _buildBookmarkList(bookmarks, 'qa'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBookmarkList(List<Bookmark> allBookmarks, String type) {
    final bookmarks = allBookmarks.where((b) => b.type == type).toList();

    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              bookmark.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              bookmark.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                ref
                    .read(bookmarkRepositoryProvider)
                    .removeBookmark(bookmark.id, bookmark.type);
                // ignore: unused_result
                ref.refresh(bookmarksProvider);
              },
            ),
            onTap: () {
              context.push(bookmark.route);
            },
          ),
        );
      },
    );
  }
}

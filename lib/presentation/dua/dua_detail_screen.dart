import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/services/audio_player_service.dart';
import 'package:islamic_app/domain/entities/dua.dart';
import 'package:islamic_app/domain/entities/bookmark.dart';
import 'package:islamic_app/data/repositories/bookmark_repository.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

class DuaDetailScreen extends ConsumerStatefulWidget {
  final Dua dua;

  const DuaDetailScreen({super.key, required this.dua});

  @override
  ConsumerState<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends ConsumerState<DuaDetailScreen> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioPlayerServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dua Details'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final bookmarksAsync = ref.watch(bookmarksStreamProvider);
              final isBookmarked = bookmarksAsync.maybeWhen(
                data: (bookmarks) => bookmarks.any(
                  (b) => b.id == widget.dua.id.toString() && b.type == 'dua',
                ),
                orElse: () => false,
              );

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                color: isBookmarked ? AppColors.primaryGold : null,
                onPressed: () async {
                  final repo = ref.read(bookmarkRepositoryProvider);
                  if (isBookmarked) {
                    await repo.removeBookmark(widget.dua.id.toString(), 'dua');
                    if (context.mounted) {
                      AppSnackbar.showInfo(context, 'Bookmark removed');
                    }
                  } else {
                    final bookmark = Bookmark(
                      id: widget.dua.id.toString(),
                      type: 'dua',
                      title: widget.dua.arabic.length > 50
                          ? '${widget.dua.arabic.substring(0, 50)}...'
                          : widget.dua.arabic,
                      subtitle: widget.dua.reference,
                      content: widget.dua.translation,
                      route: '/dua-detail', // Note: Check routing if this works
                      timestamp: DateTime.now(),
                    );
                    await repo.addBookmark(bookmark);
                    if (context.mounted) {
                      AppSnackbar.showSuccess(context, 'Bookmarked!');
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.dua.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      height: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    widget.dua.translation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reference: ${widget.dua.reference}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                if (_isPlaying) {
                  await audioService.stop();
                  setState(() => _isPlaying = false);
                } else {
                  setState(() => _isPlaying = true);
                  // Mock audio URL for demo if empty
                  final url = widget.dua.audio.isNotEmpty
                      ? widget.dua.audio
                      : 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
                  await audioService.setPlaylist([url]);
                  await audioService.play();
                  // Reset state when finished (simple implementation)
                  // In real app, listen to playerStateStream
                  setState(() => _isPlaying = false);
                }
              },
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isPlaying ? 'Stop Audio' : 'Play Audio'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/services/audio_player_service.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioPlayerServiceProvider);

    return StreamBuilder<bool>(
      stream: audioService.player.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        return StreamBuilder<Duration?>(
          stream: audioService.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data;
            // Only show if we have a valid duration (implies audio is loaded)
            if (duration == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Quran Audio',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        StreamBuilder<Duration>(
                          stream: audioService.positionStream,
                          builder: (context, posSnapshot) {
                            final pos = posSnapshot.data ?? Duration.zero;
                            return LinearProgressIndicator(
                              value: duration.inMilliseconds > 0
                                  ? pos.inMilliseconds / duration.inMilliseconds
                                  : 0,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                              minHeight: 2,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (isPlaying) {
                        audioService.pause();
                      } else {
                        audioService.play();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => audioService.stop(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

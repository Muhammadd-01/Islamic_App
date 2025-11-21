import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/services/audio_player_service.dart';
import 'package:islamic_app/presentation/quran_audio/quran_audio_provider.dart';

class SurahAudioScreen extends ConsumerStatefulWidget {
  final String surahId;
  final String surahName;

  const SurahAudioScreen({
    super.key,
    required this.surahId,
    required this.surahName,
  });

  @override
  ConsumerState<SurahAudioScreen> createState() => _SurahAudioScreenState();
}

class _SurahAudioScreenState extends ConsumerState<SurahAudioScreen> {
  int _currentAyahIndex = 0;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    final surahAudio = await ref
        .read(quranAudioRepositoryProvider)
        .getSurahAudio(widget.surahId);

    // Check if already playing this surah to avoid reloading
    // For simplicity, we reload for now, or we could check the playlist
    // But since we want to start from the beginning or saved state:

    final urls = surahAudio.ayahs.map((a) => a.url).toList();
    await audioService.setPlaylist(urls);

    // Listeners
    audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    audioService.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    audioService.durationStream.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur ?? Duration.zero;
        });
      }
    });

    audioService.currentIndexStream.listen((index) {
      if (mounted && index != null) {
        setState(() {
          _currentAyahIndex = index;
        });
        // Save last played
        ref
            .read(quranAudioRepositoryProvider)
            .saveLastPlayedAyah(widget.surahId, index);
      }
    });

    audioService.play();
  }

  @override
  void dispose() {
    // Do NOT dispose the global audio service
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final surahAudioAsync = ref.watch(surahAudioProvider(widget.surahId));
    final audioService = ref.watch(audioPlayerServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.surahName), centerTitle: true),
      body: surahAudioAsync.when(
        data: (surahAudio) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: surahAudio.ayahs.length,
                  itemBuilder: (context, index) {
                    final isCurrentAyah = index == _currentAyahIndex;
                    return Card(
                      color: isCurrentAyah
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : null,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCurrentAyah
                              ? AppColors.primary
                              : Colors.grey[300],
                          foregroundColor: isCurrentAyah
                              ? Colors.white
                              : Colors.black,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          'Ayah ${index + 1}',
                          style: TextStyle(
                            fontWeight: isCurrentAyah
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isCurrentAyah
                            ? const Icon(
                                Icons.graphic_eq,
                                color: AppColors.primary,
                                size: 24,
                              )
                            : null,
                        onTap: () async {
                          await audioService.seek(Duration.zero, index: index);
                          audioService.play();
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Slider.adaptive(
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        audioService.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position)),
                          Text(_formatDuration(_duration)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 36),
                          onPressed: () => audioService.seekToPrevious(),
                        ),
                        const SizedBox(width: 24),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              if (_isPlaying) {
                                audioService.pause();
                              } else {
                                audioService.play();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 36),
                          onPressed: () => audioService.seekToNext(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

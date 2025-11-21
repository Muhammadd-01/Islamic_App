import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> setPlaylist(List<String> urls, {int initialIndex = 0}) async {
    try {
      // ignore: deprecated_member_use
      final playlist = ConcatenatingAudioSource(
        children: urls.map((url) => AudioSource.uri(Uri.parse(url))).toList(),
      );
      await _player.setAudioSource(playlist, initialIndex: initialIndex);
    } catch (e) {
      debugPrint('Error setting playlist: $e');
    }
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();
  Future<void> stop() async => await _player.stop();
  Future<void> seek(Duration position, {int? index}) async =>
      await _player.seek(position, index: index);
  Future<void> seekToNext() async => await _player.seekToNext();
  Future<void> seekToPrevious() async => await _player.seekToPrevious();

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  bool get isPlaying => _player.playing;

  void dispose() {
    _player.dispose();
  }
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

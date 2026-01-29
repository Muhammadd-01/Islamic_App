import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/datasources/quran_audio_data_source.dart';
import 'package:islamic_app/data/repositories/quran_audio_repository_impl.dart';
import 'package:islamic_app/domain/entities/quran_audio.dart';
import 'package:islamic_app/domain/repositories/quran_audio_repository.dart';

final quranAudioDataSourceProvider = Provider<QuranAudioDataSource>((ref) {
  return LocalQuranAudioDataSource();
});

final quranAudioRepositoryProvider = Provider<QuranAudioRepository>((ref) {
  return QuranAudioRepositoryImpl(ref.watch(quranAudioDataSourceProvider));
});

final recitersProvider = StreamProvider<List<Reciter>>((ref) {
  return FirebaseFirestore.instance.collection('reciters').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs
        .map((doc) => Reciter.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  });
});

final adhansProvider = StreamProvider<List<Adhan>>((ref) {
  return FirebaseFirestore.instance.collection('adhans').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs
        .map((doc) => Adhan.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  });
});

final selectedReciterProvider = FutureProvider<String?>((ref) async {
  return ref.watch(quranAudioRepositoryProvider).getSelectedReciter();
});

class SelectedAdhanNotifier extends Notifier<String> {
  @override
  String build() => 'default';

  void setAdhan(String adhanId) {
    state = adhanId;
  }
}

final selectedAdhanProvider = NotifierProvider<SelectedAdhanNotifier, String>(
  SelectedAdhanNotifier.new,
);

final surahAudioProvider = FutureProvider.family<SurahAudio, String>((
  ref,
  surahId,
) async {
  return ref.watch(quranAudioRepositoryProvider).getSurahAudio(surahId);
});

class Adhan {
  final String id;
  final String name;
  final String audioUrl;
  final String? description;

  Adhan({
    required this.id,
    required this.name,
    required this.audioUrl,
    this.description,
  });

  factory Adhan.fromMap(Map<String, dynamic> map) {
    return Adhan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      description: map['description'],
    );
  }
}

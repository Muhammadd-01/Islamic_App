import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/repositories/muslim_scientists_repository_impl.dart';
import 'package:islamic_app/domain/entities/invention.dart';
import 'package:islamic_app/domain/entities/scientist.dart';
import 'package:islamic_app/domain/repositories/muslim_scientists_repository.dart';

final muslimScientistsRepositoryProvider = Provider<MuslimScientistsRepository>(
  (ref) {
    return MuslimScientistsRepositoryImpl(FirebaseFirestore.instance);
  },
);

final inventionsProvider = FutureProvider<List<Invention>>((ref) async {
  final repository = ref.read(muslimScientistsRepositoryProvider);
  return repository.getInventions();
});

final scientistsProvider = FutureProvider<List<Scientist>>((ref) async {
  final repository = ref.read(muslimScientistsRepositoryProvider);
  return repository.getScientists();
});

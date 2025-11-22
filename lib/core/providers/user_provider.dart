import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/repositories/user_repository.dart';
import 'package:islamic_app/data/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final userStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userProfileStreamProvider = StreamProvider.autoDispose((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUserStream();
});

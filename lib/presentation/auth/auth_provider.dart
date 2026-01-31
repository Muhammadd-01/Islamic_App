import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamic_app/data/repositories/auth_repository_impl.dart';
import 'package:islamic_app/domain/entities/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/repositories/auth_repository.dart';
import 'package:islamic_app/data/repositories/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final userRepo = UserRepository();
  return FirebaseAuthRepository(FirebaseAuth.instance, userRepo);
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

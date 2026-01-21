import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/repositories/user_repository.dart';
import 'package:islamic_app/data/services/storage_service.dart';
import 'package:islamic_app/domain/entities/app_user.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Reactive provider for the current user's Firestore profile
final userProfileProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  final authUser = authState.value;

  if (authUser == null) return Stream.value(null);

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUserStream().map((snapshot) {
    if (!snapshot.exists)
      return authUser; // Fallback to auth metadata while doc is creating

    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) return authUser;

    return AppUser(
      uid: data['uid'] ?? authUser.uid,
      email: data['email'] ?? authUser.email,
      name: data['name'] ?? authUser.name,
      imageUrl: data['imageUrl'] ?? authUser.imageUrl,
      phone: data['phone'] ?? authUser.phone,
    );
  });
});

/// Legacy provider for backward compatibility, now watching the reactive profile
final userStreamProvider = Provider<AppUser?>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.value;
});

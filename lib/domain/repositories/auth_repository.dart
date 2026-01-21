import 'package:islamic_app/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser?> signInWithEmailAndPassword(String email, String password);
  Future<AppUser?> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? fullName,
    String? phone,
  });
  Future<void> signOut();
  AppUser? get currentUser;

  // Future methods for social logins (to be implemented by specific repos)
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithFacebook();
}

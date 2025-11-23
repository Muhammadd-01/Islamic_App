import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? fullName,
    String? phone,
  });
  Future<void> signOut();
  User? get currentUser;
}

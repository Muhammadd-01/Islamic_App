import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:islamic_app/domain/repositories/auth_repository.dart';
import 'package:islamic_app/data/repositories/user_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  FirebaseAuthRepository(this._firebaseAuth, this._userRepository);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? fullName,
    String? phone,
  }) async {
    UserCredential? credential;
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _userRepository.createUserProfile(
          credential.user!,
          fullName: fullName,
          phone: phone,
        );
      }
      return credential.user;
    } catch (e) {
      // Rollback: Delete the user if profile creation failed
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
          print("Rolled back user creation due to profile error");
        } catch (deleteError) {
          print("Failed to rollback user creation: $deleteError");
        }
      }
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        await _userRepository.createUserProfile(userCredential.user!);
      }
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;

      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        await _userRepository.createUserProfile(userCredential.user!);
      }
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}

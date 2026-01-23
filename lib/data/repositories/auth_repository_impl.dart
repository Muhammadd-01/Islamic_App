import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:islamic_app/domain/entities/app_user.dart';
import 'package:islamic_app/domain/repositories/auth_repository.dart';
import 'package:islamic_app/data/repositories/user_repository.dart';
import 'package:islamic_app/data/services/notification_service.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  FirebaseAuthRepository(this._firebaseAuth, this._userRepository);

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((user) {
        if (user == null) return null;
        return _mapFirebaseUserToAppUser(user);
      });

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUserToAppUser(user);
  }

  @override
  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) return null;
      final user = _mapFirebaseUserToAppUser(credential.user!);
      await NotificationService.setExternalUserId(user.uid);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser?> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? fullName,
    String? phone,
  }) async {
    firebase.UserCredential? credential;
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _userRepository.createUserProfile(
          uid: credential.user!.uid,
          email: email,
          name: fullName,
          phone: phone,
        );
        final user = _mapFirebaseUserToAppUser(credential.user!);
        await NotificationService.setExternalUserId(user.uid);
        return user;
      }
      return null;
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

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        await _userRepository.createUserProfile(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName,
          imageUrl: userCredential.user!.photoURL,
        );
        final appUser = _mapFirebaseUserToAppUser(userCredential.user!);
        await NotificationService.setExternalUserId(appUser.uid);
        return appUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;

      final firebase.OAuthCredential credential = firebase
          .FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        await _userRepository.createUserProfile(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName,
          imageUrl: userCredential.user!.photoURL,
        );
        final appUser = _mapFirebaseUserToAppUser(userCredential.user!);
        await NotificationService.setExternalUserId(appUser.uid);
        return appUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await NotificationService.removeExternalUserId();
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

  AppUser _mapFirebaseUserToAppUser(firebase.User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      imageUrl: user.photoURL,
      phone: user.phoneNumber,
    );
  }
}

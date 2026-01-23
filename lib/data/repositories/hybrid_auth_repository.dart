import 'dart:async';
import 'package:islamic_app/domain/entities/app_user.dart';
import 'package:islamic_app/domain/repositories/auth_repository.dart';

class HybridAuthRepository implements AuthRepository {
  final AuthRepository _firebaseAuth;
  final AuthRepository _supabaseAuth;

  final _authStateController = StreamController<AppUser?>.broadcast();
  StreamSubscription<AppUser?>? _fbSub;
  StreamSubscription<AppUser?>? _sbSub;

  HybridAuthRepository({
    required AuthRepository firebaseAuth,
    required AuthRepository supabaseAuth,
  }) : _firebaseAuth = firebaseAuth,
       _supabaseAuth = supabaseAuth {
    _initStreams();
  }

  void _initStreams() {
    // Listen to Firebase auth changes
    _fbSub = _firebaseAuth.authStateChanges.listen((user) {
      if (user != null) {
        _authStateController.add(user);
      } else {
        // Only add null if BOTH are null
        if (_supabaseAuth.currentUser == null) {
          _authStateController.add(null);
        }
      }
    });

    // Listen to Supabase auth changes
    _sbSub = _supabaseAuth.authStateChanges.listen((user) {
      if (user != null) {
        _authStateController.add(user);
      } else {
        // Only add null if BOTH are null
        if (_firebaseAuth.currentUser == null) {
          _authStateController.add(null);
        }
      }
    });
  }

  @override
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  @override
  AppUser? get currentUser =>
      _firebaseAuth.currentUser ?? _supabaseAuth.currentUser;

  @override
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) {
    // Manual login -> Firebase
    return _firebaseAuth.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<AppUser?> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? fullName,
    String? phone,
  }) {
    // Manual registration -> Firebase
    return _firebaseAuth.signUpWithEmailAndPassword(
      email,
      password,
      fullName: fullName,
      phone: phone,
    );
  }

  @override
  Future<AppUser?> signInWithGoogle() {
    // Social login -> Firebase
    return _firebaseAuth.signInWithGoogle();
  }

  @override
  Future<AppUser?> signInWithFacebook() {
    // Social login -> Firebase
    return _firebaseAuth.signInWithFacebook();
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _supabaseAuth.signOut()]);
    _authStateController.add(null);
  }

  void dispose() {
    _fbSub?.cancel();
    _sbSub?.cancel();
    _authStateController.close();
  }
}

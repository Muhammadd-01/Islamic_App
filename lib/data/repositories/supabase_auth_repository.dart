import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:islamic_app/domain/entities/app_user.dart';
import 'package:islamic_app/domain/repositories/auth_repository.dart';
import 'package:islamic_app/data/repositories/user_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final UserRepository _userRepository;

  SupabaseAuthRepository(this._userRepository) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user;
      final event = data.event;

      if (user != null &&
          (event == AuthChangeEvent.signedIn ||
              event == AuthChangeEvent.tokenRefreshed)) {
        final appUser = _mapSupabaseUserToAppUser(user);
        await _syncUserToFirestore(appUser);
      }
    });
  }

  @override
  Stream<AppUser?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((data) {
        final user = data.session?.user;
        if (user == null) return null;
        return _mapSupabaseUserToAppUser(user);
      });

  @override
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return _mapSupabaseUserToAppUser(user);
  }

  @override
  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      final appUser = _mapSupabaseUserToAppUser(response.user!);
      await _syncUserToFirestore(appUser);
      return appUser;
    }
    return null;
  }

  @override
  Future<AppUser?> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? fullName,
    String? phone,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
    );
    if (response.user != null) {
      final appUser = _mapSupabaseUserToAppUser(response.user!);
      await _syncUserToFirestore(appUser, name: fullName, phone: phone);
      return appUser;
    }
    return null;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.islamicapp.islamic-app://login-callback',
    );
    return currentUser;
  }

  @override
  Future<AppUser?> signInWithFacebook() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: 'com.islamicapp.islamic-app://login-callback',
    );
    return currentUser;
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  AppUser _mapSupabaseUserToAppUser(User user) {
    return AppUser(
      uid: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
      imageUrl:
          user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
      phone: user.phone,
    );
  }

  Future<void> _syncUserToFirestore(
    AppUser user, {
    String? name,
    String? phone,
  }) async {
    try {
      await _userRepository.createUserProfile(
        uid: user.uid,
        email: user.email,
        name: name ?? user.name,
        phone: phone ?? user.phone,
        imageUrl: user.imageUrl,
      );
    } catch (e) {
      print('Failed to sync Supabase user to Firestore: $e');
    }
  }
}

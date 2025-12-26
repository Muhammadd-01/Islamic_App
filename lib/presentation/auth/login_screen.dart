import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/data/repositories/auth_repository_impl.dart';
import 'package:islamic_app/data/repositories/user_repository.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';
import 'package:islamic_app/presentation/widgets/glassmorphism_alert.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      // Check if user exists first
      final userRepo = UserRepository();
      final userExists = await userRepo.userExistsByEmail(
        _emailController.text.trim(),
      );

      if (!userExists) {
        setState(() => _isLoading = false);
        if (mounted) {
          await GlassmorphismAlert.show(
            context,
            title: 'User Not Found',
            message: 'User does not exist.\nPlease sign up first.',
            buttonText: 'Go to Sign Up',
            icon: Icons.person_off,
            iconColor: Colors.orange,
            onPressed: () {
              context.go('/signup');
            },
          );
        }
        return;
      }

      // Proceed with login
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Login failed';
        if (e.code == 'user-not-found') {
          message = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email format';
        }

        AppSnackbar.showError(context, message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Login failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authRepo =
          ref.read(authRepositoryProvider) as FirebaseAuthRepository;
      await authRepo.signInWithGoogle();
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Google Sign-In failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _isLoading = true);
    try {
      final authRepo =
          ref.read(authRepositoryProvider) as FirebaseAuthRepository;
      await authRepo.signInWithFacebook();
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Facebook Sign-In failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.mosque, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Sign In', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithFacebook,
                icon: const Icon(Icons.facebook, size: 24),
                label: const Text('Continue with Facebook'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () => context.push('/signup'),
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

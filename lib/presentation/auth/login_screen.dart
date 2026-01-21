import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

/// DeenSphere Login Screen
/// Premium dark aesthetic with gold accents
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      // Direct login - Auth Repository handles errors if user not found
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        String message = 'Login failed';
        final errorStr = e.toString().toLowerCase();

        if (errorStr.contains('invalid login credentials') ||
            errorStr.contains('invalid-credential')) {
          message = 'Invalid email or password';
        } else if (errorStr.contains('user not found')) {
          message = 'No user found with this email';
        } else if (errorStr.contains('invalid email')) {
          message = 'Invalid email format';
        }

        AppSnackbar.showError(context, message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) context.go('/home');
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
      await ref.read(authRepositoryProvider).signInWithFacebook();
      if (mounted) context.go('/home');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // DeenSphere Logo
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/deensphere_logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Welcome Text
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryWhite,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.mutedGray),
                ),
                const SizedBox(height: 40),
                // Email Field
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.primaryWhite),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primaryGold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: AppColors.primaryWhite),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primaryGold,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.mutedGray,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In Button with Gold Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: _isLoading ? null : AppColors.primaryGoldGradient,
                    color: _isLoading ? AppColors.mutedGray : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primaryGold.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _login,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.iconBlack,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.iconBlack,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // OR Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.softIconGray,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: AppColors.mutedGray),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.softIconGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Google Sign In
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryWhite,
                    side: const BorderSide(color: AppColors.softIconGray),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Facebook Sign In
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithFacebook,
                  icon: const Icon(Icons.facebook, size: 24),
                  label: const Text('Continue with Facebook'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryWhite,
                    side: const BorderSide(color: AppColors.softIconGray),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Forgot Password
                TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGold,
                  ),
                  child: const Text('Forgot Password?'),
                ),
                // Sign Up Link
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Don\'t have an account? ',
                      style: TextStyle(color: AppColors.mutedGray),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

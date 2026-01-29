import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';
import 'package:islamic_app/presentation/widgets/glassmorphism_alert.dart';

/// DeenSphere Forgot Password Screen
/// Premium dark aesthetic with gold accents
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authRepo = ref.read(authRepositoryProvider);
        await authRepo.sendPasswordResetEmail(_emailController.text.trim());

        if (mounted) {
          await GlassmorphismAlert.show(
            context,
            title: 'Email Sent!',
            message:
                'Password reset link has been sent to your email.\nPlease check your inbox.',
            buttonText: 'Go to Login',
            icon: Icons.email_outlined,
            iconColor: AppColors.primaryGold,
            onPressed: () {
              context.go('/login');
            },
          );
        }
      } catch (e) {
        if (mounted) {
          await GlassmorphismAlert.show(
            context,
            title: 'Error',
            message:
                'Failed to send reset email.\nPlease check your email address.',
            buttonText: 'Try Again',
            icon: Icons.error_outline,
            iconColor: AppColors.error,
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryWhite,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Forgot Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // Icon with gold glow
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.goldTileGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 25,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 50,
                            color: AppColors.iconBlack,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Reset Your Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Enter your email address and we\'ll send you a link to reset your password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedGray,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Email Field
                        TextFormField(
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        // Send Reset Link Button with Gold Gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: _isLoading
                                ? null
                                : AppColors.primaryGoldGradient,
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
                              onTap: _isLoading ? null : _sendResetEmail,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                          'Send Reset Link',
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
                        // Back to Login
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryGold,
                          ),
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

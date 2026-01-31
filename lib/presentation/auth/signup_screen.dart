import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';
import 'package:islamic_app/presentation/widgets/country_code_picker.dart';

/// DeenSphere Sign Up Screen
/// Premium dark aesthetic with gold accents
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  CountryCode _selectedCountry =
      CountryCodeDropdown.countries[0]; // Default to PK

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final fullPhone = _phoneController.text.trim().isEmpty
            ? null
            : '${_selectedCountry.code}${_phoneController.text.trim()}';

        await ref
            .read(authRepositoryProvider)
            .signUpWithEmailAndPassword(
              _emailController.text.trim(),
              _passwordController.text,
              fullName: _nameController.text.trim(),
              phone: fullPhone,
            );

        if (mounted) {
          // Auto-redirect to login
          context.go('/login');
          AppSnackbar.showSuccess(context, 'Account created! Please log in.');
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, 'Sign up failed: $e');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primaryGold),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
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
                        'Create Account',
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // DeenSphere Logo
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/deensphere_logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Join DeenSphere',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start your spiritual journey today',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedGray,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Full Name Field
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.primaryWhite),
                          decoration: _buildInputDecoration(
                            label: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: AppColors.primaryWhite),
                          decoration: _buildInputDecoration(
                            label: 'Email',
                            icon: Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        // Phone Row (Dropdown + Input)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CountryCodeDropdown(
                              selectedCountry: _selectedCountry,
                              onSelected: (country) =>
                                  setState(() => _selectedCountry = country),
                              isDark: true,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                style: const TextStyle(
                                  color: AppColors.primaryWhite,
                                ),
                                decoration: _buildInputDecoration(
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: AppColors.primaryWhite),
                          decoration: _buildInputDecoration(
                            label: 'Password',
                            icon: Icons.lock_outline,
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
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          style: const TextStyle(color: AppColors.primaryWhite),
                          decoration: _buildInputDecoration(
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.mutedGray,
                              ),
                              onPressed: () => setState(
                                () => _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible,
                              ),
                            ),
                          ),
                          obscureText: !_isConfirmPasswordVisible,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        // Sign Up Button with Gold Gradient
                        SizedBox(
                          width: double.infinity,
                          child: Container(
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
                                onTap: _isLoading ? null : _signUp,
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
                                            'Create Account',
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
                            side: const BorderSide(
                              color: AppColors.softIconGray,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 50),
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
                            side: const BorderSide(
                              color: AppColors.softIconGray,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Login Link
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: AppColors.mutedGray),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyle(
                                    color: AppColors.primaryGold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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

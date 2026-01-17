import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

/// DeenSphere Onboarding Splash Screen
/// Alternative splash used in onboarding flow with premium DeenSphere branding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkBackgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // DeenSphere Logo with glow effect
              Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/deensphere_logo.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .then(delay: 200.ms)
                  .shimmer(duration: 1200.ms, color: AppColors.highlightGold),
              const SizedBox(height: 28),
              // App Name - "Deen" in white, "Sphere" in gold
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Deen',
                      style: TextStyle(color: AppColors.primaryWhite),
                    ),
                    TextSpan(
                      text: 'Sphere',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        shadows: [
                          Shadow(
                            color: AppColors.primaryGold.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 800.ms).slideY(begin: 0.5, end: 0),
              const SizedBox(height: 8),
              Text(
                'Serving Islam, Fostering Unity',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedGray.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ).animate().fade(delay: 400.ms, duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

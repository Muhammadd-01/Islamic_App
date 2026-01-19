import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _cycle = 0;
  int _target = 33;
  bool _isTapped = false;
  late AnimationController _bumpController;
  late Animation<double> _bumpAnimation;

  @override
  void initState() {
    super.initState();
    _bumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _bumpAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _bumpController, curve: Curves.easeInOut),
    );
    _bumpController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bumpController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _bumpController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _bumpController.forward(from: 0);

    setState(() {
      _isTapped = true;

      if (_target == 9999) {
        // Infinity mode - never reset
        _count++;
      } else {
        _count++;
        if (_count > _target) {
          _count = 1;
          _cycle++;
          HapticFeedback.mediumImpact();
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isTapped = false);
    });
  }

  void _reset() {
    HapticFeedback.heavyImpact();
    setState(() {
      _count = 0;
      _cycle = 0;
    });
  }

  void _setTarget(int target) {
    HapticFeedback.selectionClick();
    setState(() {
      _target = target;
      _count = 0;
      _cycle = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbeeh Counter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reset Counter',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cycle Count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.loop,
                      color: AppColors.primaryGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cycle: $_cycle',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: -0.2, end: 0),

              const SizedBox(height: 50),

              // Main Counter Button with Bump Effect
              GestureDetector(
                onTap: _increment,
                child: AnimatedBuilder(
                  animation: _bumpAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bumpAnimation.value,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryGold,
                              AppColors.primaryGold.withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGold.withValues(
                                alpha: _isTapped ? 0.6 : 0.4,
                              ),
                              blurRadius: _isTapped ? 50 : 30,
                              spreadRadius: _isTapped ? 15 : 10,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: _count.toDouble()),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                              Text(
                                _target == 9999 ? '/ ∞' : '/ $_target',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 16),

              // Tap instruction
              Text(
                'Tap to count',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  letterSpacing: 1,
                ),
              ).animate().fade(delay: 300.ms),

              const SizedBox(height: 60),

              // Target Selection with Working Buttons
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TargetButton(
                      label: '33',
                      isSelected: _target == 33,
                      onTap: () => _setTarget(33),
                    ),
                    const SizedBox(width: 8),
                    _TargetButton(
                      label: '99',
                      isSelected: _target == 99,
                      onTap: () => _setTarget(99),
                    ),
                    const SizedBox(width: 8),
                    _TargetButton(
                      label: '∞',
                      isSelected: _target == 9999,
                      onTap: () => _setTarget(9999),
                    ),
                  ],
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              // Dhikr suggestions
              Text(
                _getDhikrSuggestion(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ).animate().fade(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  String _getDhikrSuggestion() {
    switch (_target) {
      case 33:
        return 'سُبْحَانَ اللّٰهِ\nSubhanAllah (Glory be to Allah)';
      case 99:
        return 'أَسْتَغْفِرُ اللّٰهَ\nAstaghfirullah (I seek forgiveness)';
      default:
        return 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ\nLa hawla wala quwwata illa billah';
    }
  }
}

class _TargetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TargetButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

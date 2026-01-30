import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/providers/region_provider.dart';
import 'package:islamic_app/data/repositories/tasbeeh_repository.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

enum AgeGroup { child, teenager, adult, elderly }

enum DhikrType { simple, medium, long, ultraShort, unknown }

class TasbeehScreen extends ConsumerStatefulWidget {
  const TasbeehScreen({super.key});

  @override
  ConsumerState<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends ConsumerState<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _count = 0;
  int _cycle = 0;
  int _target = 33;
  String _selectedDhikr = 'SubhanAllah';
  String _dhikrArabic = 'سُبْحَانَ اللّٰهِ';

  // Local cache for non-blocking increment
  int _sessionIncrement = 0;
  int _totalUnsaved = 0;

  // Speed analytics
  double _currentRPM = 0.0;
  final List<DateTime> _recentTaps = [];
  AgeGroup _selectedAgeGroup = AgeGroup.adult;
  bool _isSpeedWarningActive = false;
  bool _isSavingProgress = false;
  int _steadyCount = 0;
  bool _isEncouragementActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDhikr();
    _loadSettings();
    // Faster decay logic: Check every 500ms
    _decayTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;

      final now = DateTime.now();
      final lastTap = _recentTaps.isEmpty ? null : _recentTaps.last;

      if (lastTap != null) {
        final silenceDuration = now.difference(lastTap).inMilliseconds;

        if (silenceDuration > 1500) {
          // Immediate drop if silent for > 1.5s
          if (_currentRPM > 0) {
            setState(() {
              _currentRPM = 0;
              _recentTaps.clear();
              _steadyCount = 0;
              _isSpeedWarningActive = false;
            });
          }
        } else if (silenceDuration > 800) {
          // Faster decay
          setState(() {
            _currentRPM *= 0.7;
          });
        }
      }
    });
  }

  late Timer _decayTimer;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final ageIndex = prefs.getInt('selected_age_group') ?? 2; // Default Adult
    if (mounted) {
      setState(() {
        _selectedAgeGroup = AgeGroup.values[ageIndex];
      });
    }
  }

  Future<void> _saveAgeGroup(AgeGroup group) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_age_group', group.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _decayTimer.cancel();
    super.dispose();
  }

  Future<void> _loadDhikr() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedDhikr =
            prefs.getString('selected_dhikr_name') ?? 'SubhanAllah';
        _dhikrArabic =
            prefs.getString('selected_dhikr_arabic') ?? 'سُبْحَانَ اللّٰهِ';
      });
    }
  }

  Future<void> _saveDhikr(String name, String arabic) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_dhikr_name', name);
    await prefs.setString('selected_dhikr_arabic', arabic);
  }

  DhikrType _getDhikrType() {
    final name = _selectedDhikr.toLowerCase();
    final arabic = _dhikrArabic;

    // Ultra-Short Dhikr (Single Word / Phrase)
    if (name == 'allah' || name == 'ya allah' || name == 'hu') {
      return DhikrType.ultraShort;
    }

    // Long Adhkār / Duʿāʾ-Based Dhikr
    if (arabic.length > 40 ||
        name.contains('la ilaha illallah') ||
        name.contains('wahdahu la') ||
        name.contains('sharika lah') ||
        name.contains('salawat') ||
        name.contains('sallallahu') ||
        name.contains('sayyidul istighfar')) {
      return DhikrType.long;
    }

    // Medium-Length Adhkār
    if (name.contains('astaghfirullah') ||
        name.contains('bihamdih') ||
        name.contains('la hawla')) {
      return DhikrType.medium;
    }

    // Simple Tasbīḥ (Short Adhkār)
    if (name.contains('subhanallah') ||
        name.contains('alhamdulillah') ||
        name.contains('allahu akbar')) {
      return DhikrType.simple;
    }

    return DhikrType.unknown;
  }

  Map<String, int> _getThresholds() {
    final type = _getDhikrType();

    // Default safe limits (Option 5)
    if (type == DhikrType.unknown) {
      return {'warn': 65, 'tooFast': 75};
    }

    switch (type) {
      case DhikrType.simple:
        switch (_selectedAgeGroup) {
          case AgeGroup.child:
            return {'warn': 41, 'tooFast': 50};
          case AgeGroup.teenager:
            return {'warn': 56, 'tooFast': 65};
          case AgeGroup.adult:
            return {'warn': 61, 'tooFast': 70};
          case AgeGroup.elderly:
            return {'warn': 46, 'tooFast': 55};
        }
      case DhikrType.medium:
        switch (_selectedAgeGroup) {
          case AgeGroup.child:
            return {'warn': 31, 'tooFast': 40};
          case AgeGroup.teenager:
            return {'warn': 41, 'tooFast': 50};
          case AgeGroup.adult:
            return {'warn': 46, 'tooFast': 55};
          case AgeGroup.elderly:
            return {'warn': 31, 'tooFast': 40};
        }
      case DhikrType.long:
        switch (_selectedAgeGroup) {
          case AgeGroup.child:
            return {'warn': 16, 'tooFast': 20};
          case AgeGroup.teenager:
            return {'warn': 21, 'tooFast': 25};
          case AgeGroup.adult:
            return {'warn': 26, 'tooFast': 30};
          case AgeGroup.elderly:
            return {'warn': 16, 'tooFast': 20};
        }
      case DhikrType.ultraShort:
        switch (_selectedAgeGroup) {
          case AgeGroup.child:
            return {'warn': 46, 'tooFast': 55};
          case AgeGroup.teenager:
            return {'warn': 61, 'tooFast': 70};
          case AgeGroup.adult:
            return {'warn': 66, 'tooFast': 75};
          case AgeGroup.elderly:
            return {'warn': 46, 'tooFast': 55};
        }
      default:
        return {'warn': 65, 'tooFast': 75};
    }
  }

  void _increment() {
    final now = DateTime.now();
    HapticFeedback.lightImpact();

    setState(() {
      _count++;
      _sessionIncrement++;
      _totalUnsaved++;

      // Manage recent taps for smoother average RPM calculation (Design Advice 6)
      _recentTaps.add(now);
      if (_recentTaps.length > 10) {
        _recentTaps.removeAt(0);
      }

      // Calculate Speed (RPM) over last few taps
      if (_recentTaps.length >= 2) {
        final duration = now.difference(_recentTaps.first).inMilliseconds;
        if (duration > 0) {
          // Average RPM over the sliding window
          double averageRPM = ((_recentTaps.length - 1) * 60000) / duration;
          _currentRPM = averageRPM;
          if (_currentRPM > 300) _currentRPM = 300; // Cap
        }
      }

      // Detect Bursts (5 taps in < 2 sec) - only if we have enough data
      if (_recentTaps.length >= 5) {
        final burstDuration = now
            .difference(_recentTaps[_recentTaps.length - 5])
            .inSeconds;
        if (burstDuration < 2) {
          _triggerSpeedWarning("Too fast! Calm your heart.");
        }
      }

      // Dynamic Speed Monitoring - Skip warnings for the first 3 taps of a sequence
      // to allow the average to stabilize and prevent "immediate exceed" on tap 2
      final thresholds = _getThresholds();
      if (_recentTaps.length >= 3) {
        if (_currentRPM > thresholds['tooFast']!) {
          _triggerSpeedWarning(_getWarningMessage());
          _steadyCount = 0;
        } else if (_currentRPM > thresholds['warn']!) {
          _isSpeedWarningActive = true;
          _steadyCount = 0;
        } else if (_currentRPM > 0) {
          // Normal range
          _isSpeedWarningActive = false;
          _steadyCount++;
          // Show encouragement every 7 steady taps for ALL age groups
          if (_steadyCount >= 7) {
            _triggerEncouragement(_getEncouragementMessage());
            _steadyCount = 0;
          }
        }
      }

      if (_count > _target && _target != 9999) {
        _count = 1;
        _cycle++;
        HapticFeedback.mediumImpact();
      }
    });

    // Save to Firestore every 10 counts or after a delay to avoid rate limiting
    if (_sessionIncrement >= 10) {
      _saveProgress();
    }
  }

  String _getWarningMessage() {
    switch (_selectedAgeGroup) {
      case AgeGroup.child:
        return "Slow down, little one. Talk to Allah beautifully! ✨";
      case AgeGroup.teenager:
        return "Stay focused! Quality over speed. 🚀";
      case AgeGroup.adult:
        return "Slow down. Dhikr is for the heart, not the counter. ❤️";
      case AgeGroup.elderly:
        return "Patience is key. Take your time with your Rabb. 🤲";
    }
  }

  String _getEncouragementMessage() {
    switch (_selectedAgeGroup) {
      case AgeGroup.child:
        return "Mashallah! You are doing great! 🌟✨";
      case AgeGroup.teenager:
        return "Keep it up! This is the perfect pace. 💪🔥";
      case AgeGroup.adult:
        return "Excellent focus. May Allah accept your dhikr. ✨🤲";
      case AgeGroup.elderly:
        return "Beautifully recited. May Allah reward you. 🤲📿";
    }
  }

  void _triggerSpeedWarning(String message) {
    if (_isSpeedWarningActive) return; // Prevent spam

    if (mounted) {
      setState(() {
        _isSpeedWarningActive = true;
      });
    }

    HapticFeedback.vibrate();
    AppSnackbar.showError(context, message);

    // Reset warning status after a short delay to allow re-triggering
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSpeedWarningActive = false;
        });
      }
    });
  }

  void _triggerEncouragement(String message) {
    if (_isEncouragementActive || !mounted) return;

    setState(() {
      _isEncouragementActive = true;
    });

    AppSnackbar.showSuccess(context, message);

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isEncouragementActive = false;
        });
      }
    });
  }

  Future<void> _saveProgress() async {
    if (_sessionIncrement == 0 || _isSavingProgress) return;

    setState(() {
      _isSavingProgress = true;
    });

    final increment = _sessionIncrement;
    _sessionIncrement = 0;
    try {
      await ref.read(tasbeehRepositoryProvider).updateCount(increment);
      if (mounted) {
        setState(() {
          _totalUnsaved -= increment;
          if (_totalUnsaved < 0) _totalUnsaved = 0;
        });
      }
    } catch (e) {
      // Restore on failure
      if (mounted) {
        setState(() {
          _sessionIncrement += increment;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProgress = false;
        });
      }
    }
  }

  void _reset() {
    HapticFeedback.heavyImpact();
    setState(() {
      _count = 0;
      _currentRPM = 0;
      _recentTaps.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbeeh Pro'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.mainBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          indicatorWeight: 3,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.analytics_outlined)),
            Tab(text: 'Competition', icon: Icon(Icons.emoji_events_outlined)),
            Tab(text: 'Library', icon: Icon(Icons.menu_book_outlined)),
          ],
        ),
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) async {
          if (didPop) {
            _saveProgress();
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCounterTab(isDark),
            _buildLeaderboardTab(),
            _buildAzkarTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterTab(bool isDark) {
    final statsAsync = ref.watch(tasbeehStatsProvider);

    return Container(
      decoration: BoxDecoration(gradient: AppColors.darkBackgroundGradient),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 10),
                      // Header Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildStatItem(
                              'DAILY',
                              statsAsync.when(
                                data: (s) =>
                                    (s.dailyCount + _totalUnsaved).toString(),
                                loading: () => '...',
                                error: (_, __) => '0',
                              ),
                              Icons.calendar_today_outlined,
                            ),
                            const SizedBox(width: 8),
                            _buildStatItem(
                              'TOTAL',
                              statsAsync.when(
                                data: (s) =>
                                    (s.totalCount + _totalUnsaved).toString(),
                                loading: () => '...',
                                error: (_, __) => '0',
                              ),
                              Icons.all_inclusive,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Dhikr Display
                      Column(
                        children: [
                          Text(
                            _dhikrArabic,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              fontFamily: 'Arabic',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                              shadows: [
                                Shadow(
                                  color: AppColors.primaryGold.withOpacity(0.3),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ).animate().fade().slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 8),
                          Text(
                            _selectedDhikr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Speed Indicator & Main Counter
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(
                          begin: 0,
                          end: (_currentRPM / 200).clamp(0.0, 1.0),
                        ),
                        builder: (context, value, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // RPM Ring
                              SizedBox(
                                width: 240,
                                height: 240,
                                child: CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 6,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _isSpeedWarningActive
                                        ? Colors.red
                                        : AppColors.primaryGold.withOpacity(
                                            0.6,
                                          ),
                                  ),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.05,
                                  ),
                                ),
                              ),

                              // Main Button - Centered within ring
                              GestureDetector(
                                    onTap: _increment,
                                    behavior: HitTestBehavior
                                        .opaque, // Ensure it catches all taps
                                    child: Container(
                                      width: 220, // Slightly larger hit area
                                      height: 220,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors
                                            .transparent, // Background to catch taps
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 200,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const RadialGradient(
                                              center: Alignment(-0.2, -0.2),
                                              colors: [
                                                Color(0xFFFFD700),
                                                Color(0xFFB8860B),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryGold
                                                    .withOpacity(0.4),
                                                spreadRadius: 2,
                                                blurRadius: 40,
                                                offset: const Offset(0, 15),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '$_count',
                                                  style: TextStyle(
                                                    fontSize: 68,
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark
                                                        ? AppColors
                                                              .mainBackground
                                                        : Colors.white,
                                                    height: 1,
                                                  ),
                                                ),
                                                Text(
                                                  'CYCLE $_cycle',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF475569),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate(target: _count.toDouble())
                                  .scale(
                                    duration: 100.ms,
                                    curve: Curves.easeOutBack,
                                    begin: const Offset(0.95, 0.95),
                                    end: const Offset(1, 1),
                                  ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 12),

                      // Performance Analytics & Wisdom Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.primaryGold.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildPerformanceMetric(
                                    'SPEED',
                                    '${_currentRPM.toInt()}',
                                    'RPM',
                                    Icons.speed,
                                    color: _isSpeedWarningActive
                                        ? Colors.red
                                        : null,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  _buildPerformanceMetric(
                                    'TARGET',
                                    _target == 9999 ? '∞' : '$_target',
                                    'COUNT',
                                    Icons.flag_outlined,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  _buildPerformanceMetric(
                                    'STREAK',
                                    statsAsync.when(
                                      data: (s) => s.streakCount.toString(),
                                      loading: () => '0',
                                      error: (_, __) => '0',
                                    ),
                                    'DAYS',
                                    Icons.local_fire_department_outlined,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildWisdomCard(isDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Controls
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Text(
                              'YOUR AGE GROUP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: AgeGroup.values.map((group) {
                                  final isSelected = _selectedAgeGroup == group;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _selectedAgeGroup = group;
                                      });
                                      _saveAgeGroup(group);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryGold.withOpacity(
                                                0.2,
                                              )
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryGold
                                              : Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        group.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AppColors.primaryGold
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Controls
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...[33, 99, 9999].map((t) => _buildTargetButton(t)),
                            const SizedBox(width: 12),
                            Tooltip(
                              message: 'Reset Counter',
                              child: _buildCircleAction(
                                Icons.refresh,
                                _reset,
                                Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Save Progress to Cloud',
                              child: _buildCircleAction(
                                Icons.save_outlined,
                                _saveProgress,
                                AppColors.primaryGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankBadge(int index, Color color, bool isTopThree) {
    if (!isTopThree) {
      return Text(
        '${index + 1}',
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: Colors.grey,
        ),
      );
    }

    // Sizes for 1st, 2nd, 3rd (Decreasing size as requested)
    final badgeSizes = [40.0, 34.0, 28.0];
    final iconSizes = [24.0, 20.0, 16.0];

    return Container(
          width: badgeSizes[index],
          height: badgeSizes[index],
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Islamic-style "Crown/Turban" representation
              // Combining architecture icon with premium badge
              Positioned(
                top: 2,
                child: Icon(
                  Icons.architecture, // Looks like a dome/turban ornament
                  color: color,
                  size: iconSizes[index] * 0.7,
                ),
              ),
              Positioned(
                top: index == 0 ? 10 : 8,
                child: Icon(
                  Icons.workspace_premium,
                  color: color,
                  size: iconSizes[index],
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: 2.seconds,
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
        )
        .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.4));
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.primaryGold),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: AppColors.primaryGold,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetric(
    String label,
    String value,
    String unit,
    IconData icon, {
    Color? color,
  }) {
    final displayColor = color ?? AppColors.primaryGold;
    return Column(
      children: [
        Icon(icon, size: 18, color: displayColor),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildTargetButton(int target) {
    final isSelected = _target == target;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _target = target;
          _count = 0;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          target == 9999 ? '∞' : '$target',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);
    final regionsAsync = ref.watch(regionsStreamProvider);

    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: regionsAsync.when(
              data: (regions) {
                final items = ['Global', ...regions];
                final currentDisplay = items.contains(selectedRegion)
                    ? selectedRegion
                    : 'Global';

                return PopupMenuButton<String>(
                  onSelected: (val) {
                    ref.read(selectedRegionProvider.notifier).setRegion(val);
                  },
                  offset: const Offset(0, 50),
                  position: PopupMenuPosition.under,
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 70,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1A1A1A)
                      : Colors.white,
                  itemBuilder: (context) => items
                      .map(
                        (r) => PopupMenuItem(
                          value: r,
                          child: Text(
                            '$r Ranking',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$currentDisplay Ranking',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const Text('Error loading regions'),
            ),
          ),
        ),
        Expanded(
          child: leaderboardAsync.when(
            skipLoadingOnReload: true,
            data: (entries) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isTopThree = index < 3;
                final colors = [
                  const Color(0xFFFFD700), // Gold
                  const Color(0xFFC0C0C0), // Silver
                  const Color(0xFFCD7F32), // Bronze
                ];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isTopThree
                        ? colors[index].withOpacity(0.1)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isTopThree
                          ? colors[index].withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: SizedBox(
                      width: 70,
                      child: Row(
                        children: [
                          _buildRankBadge(index, colors[index], isTopThree),
                          const Spacer(),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold.withValues(alpha: 0.4),
                                  AppColors.primaryGold.withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child:
                                (entry.imageUrl != null &&
                                    entry.imageUrl!.isNotEmpty)
                                ? ClipOval(
                                    child: Image.network(
                                      entry.imageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1,
                                                color: AppColors.primaryGold,
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildUserInitials(
                                                entry.userName,
                                              ),
                                    ),
                                  )
                                : _buildUserInitials(entry.userName),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      entry.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      entry.region ?? 'World',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.totalCount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            ),
            error: (e, _) => Center(child: Text('Load Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildAzkarTab() {
    final azkarAsync = ref.watch(azkarProvider);

    return azkarAsync.when(
      data: (azkarList) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        itemCount: azkarList.length,
        itemBuilder: (context, index) {
          final azkar = azkarList[index];
          final isSelected = _selectedDhikr == azkar['name'];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDhikr = azkar['name']!;
                  _dhikrArabic = azkar['arabic']!;
                  _count = 0;
                  _saveDhikr(_selectedDhikr, _dhikrArabic);
                  _tabController.animateTo(0);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            azkar['arabic']!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'Arabic',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            azkar['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            azkar['meaning']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryGold,
                        size: 30,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildUserInitials(String name) {
    if (name.isEmpty) return const Icon(Icons.person, size: 20);
    final initials = name.trim().split(' ').take(2).map((s) => s[0]).join();
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primaryGold,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWisdomCard(bool isDark) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: AppColors.primaryGold.withValues(alpha: 0.6),
                size: 24,
              ),
              const SizedBox(height: 8),
              const Text(
                "Look at those who are beneath you and do not look at those who are above you, for it is more suitable that you should not consider as less the blessing of Allah.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "— Sahih Muslim 2963",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOut)
        .shimmer(
          delay: 2.seconds,
          duration: 2.seconds,
          color: AppColors.primaryGold.withValues(alpha: 0.1),
        );
  }
}

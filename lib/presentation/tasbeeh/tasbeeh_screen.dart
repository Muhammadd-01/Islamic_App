import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/providers/region_provider.dart';
import 'package:islamic_app/data/repositories/tasbeeh_repository.dart';

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
  DateTime? _lastTapTime;
  double _currentRPM = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDhikr();
    // Periodically decay speed if no taps
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted && _currentRPM > 0) {
        setState(() {
          _currentRPM *= 0.8; // Decay speed
          if (_currentRPM < 1) _currentRPM = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  void _increment() {
    final now = DateTime.now();
    HapticFeedback.lightImpact();

    setState(() {
      _count++;
      _sessionIncrement++;
      _totalUnsaved++;

      // Calculate Speed (RPM)
      if (_lastTapTime != null) {
        final difference = now.difference(_lastTapTime!).inMilliseconds;
        if (difference > 0) {
          double instantRPM = 60000 / difference;
          // Apply some smoothing
          _currentRPM = (_currentRPM * 0.6) + (instantRPM * 0.4);
          if (_currentRPM > 300) _currentRPM = 300; // Cap realistic speed
        }
      }
      _lastTapTime = now;

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

  Future<void> _saveProgress() async {
    if (_sessionIncrement == 0) return;
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
    }
  }

  void _reset() {
    HapticFeedback.heavyImpact();
    setState(() {
      _count = 0;
      _currentRPM = 0;
      _lastTapTime = null;
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
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
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
                            const Spacer(),
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

                      const Spacer(),

                      // Dhikr Display
                      Column(
                        children: [
                          Text(
                            _dhikrArabic,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 42,
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
                          const SizedBox(height: 10),
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

                      const SizedBox(height: 50),

                      // Speed Indicator & Main Counter
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // RPM Ring
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: _currentRPM / 200, // Max 200 RPM scale
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGold.withOpacity(0.5),
                              ),
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),

                          // Main Button
                          GestureDetector(
                                onTap: _increment,
                                child: Container(
                                  width: 240,
                                  height: 240,
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
                                            fontSize: 90,
                                            fontWeight: FontWeight.w900,
                                            color: isDark
                                                ? AppColors.mainBackground
                                                : Colors.white,
                                            height: 1,
                                          ),
                                        ),
                                        Text(
                                          'CYCLE $_cycle',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ],
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
                      ),

                      const Spacer(),

                      // Performance Analytics
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPerformanceMetric(
                                'SPEED',
                                '${_currentRPM.toInt()}',
                                'RPM',
                                Icons.speed,
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
                            _buildCircleAction(
                              Icons.refresh,
                              _reset,
                              Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            _buildCircleAction(
                              Icons.save_outlined,
                              _saveProgress,
                              AppColors.primaryGold,
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
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryGold),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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
                          Text(
                            index == 0 ? '👑' : '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: isTopThree ? colors[index] : Colors.grey,
                            ),
                          ),
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
}

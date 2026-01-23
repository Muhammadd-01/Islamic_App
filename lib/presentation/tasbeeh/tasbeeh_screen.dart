import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/data/repositories/tasbeeh_repository.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      _sessionIncrement++;
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
    await ref.read(tasbeehRepositoryProvider).updateCount(increment);
  }

  void _reset() {
    HapticFeedback.heavyImpact();
    setState(() {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deen Tasbeeh'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Counter', icon: Icon(Icons.touch_app_outlined)),
            Tab(text: 'Leaderboard', icon: Icon(Icons.emoji_events_outlined)),
            Tab(text: 'Azkar', icon: Icon(Icons.list_alt_outlined)),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          await _saveProgress();
          return true;
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
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.asData?.value;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [Colors.black, Colors.grey.shade900]
              : [Colors.white, Colors.grey.shade100],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // User Info & Analytics Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user?.imageUrl != null
                      ? NetworkImage(user!.imageUrl!)
                      : null,
                  child: user?.imageUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Assalamu Alaikum',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Keep up the good work!',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatCard(
                  'Daily',
                  statsAsync.when(
                    data: (s) => (s.dailyCount + _sessionIncrement).toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Total',
                  statsAsync.when(
                    data: (s) => (s.totalCount + _sessionIncrement).toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Dhikr Display
          Text(
            _dhikrArabic,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
          ).animate().fade().scale(),
          Text(
            _selectedDhikr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),

          const SizedBox(height: 40),

          // Main Counter
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppColors.primaryGold, Color(0xFFC5A059)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    spreadRadius: 10,
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$_count',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ).animate().scale(duration: 200.ms, curve: Curves.easeOut),

          const SizedBox(height: 20),

          // Cycle Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Cycles: $_cycle',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Analytics Section (On Scroll)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Divider(),
                const Text(
                  'Your Activity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildAnalyticsCard('Weekly', '1,240', Icons.bar_chart),
                    const SizedBox(width: 15),
                    _buildAnalyticsCard('Monthly', '5,820', Icons.show_chart),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...[33, 99, 9999].map((t) => _buildTargetButton(t)),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: Colors.grey),
                tooltip: 'Reset Session',
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.primaryGold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 24),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          target == 9999 ? '∞' : target.toString(),
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final selectedRegion = ref.watch(leaderboardRegionProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedRegion,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  items:
                      [
                            'Global',
                            'Pakistan',
                            'Saudi Arabia',
                            'UAE',
                            'USA',
                            'UK',
                            'India',
                          ]
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null)
                      ref.read(leaderboardRegionProvider.notifier).update(val);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: leaderboardAsync.when(
            data: (entries) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isTopThree = index < 3;
                return Card(
                  elevation: isTopThree ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTopThree ? AppColors.primaryGold : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundImage: entry.imageUrl != null
                              ? NetworkImage(entry.imageUrl!)
                              : null,
                          child: entry.imageUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ],
                    ),
                    title: Text(
                      entry.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      entry.region ?? 'Global',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Text(
                      entry.totalCount.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            ),
            error: (e, _) =>
                Center(child: Text('Error loading leaderboard: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildAzkarTab() {
    final azkarList = [
      {
        'name': 'SubhanAllah',
        'arabic': 'سُبْحَانَ اللّٰهِ',
        'meaning': 'Glory be to Allah',
      },
      {
        'name': 'Alhamdulillah',
        'arabic': 'الْحَمْدُ لِلّٰهِ',
        'meaning': 'Praise be to Allah',
      },
      {
        'name': 'Allahu Akbar',
        'arabic': 'اللّٰهُ أَكْبَرُ',
        'meaning': 'Allah is the Greatest',
      },
      {
        'name': 'Astaghfirullah',
        'arabic': 'أَسْتَغْفِرُ اللّٰهَ',
        'meaning': 'I seek forgiveness from Allah',
      },
      {
        'name': 'La ilaha illa Allah',
        'arabic': 'لَا إِلٰهَ إِلَّا اللّٰهُ',
        'meaning': 'There is no god but Allah',
      },
      {
        'name': 'Subhanallahi wa bihamdihi',
        'arabic': 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ',
        'meaning': 'Glory and praise be to Allah',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: azkarList.length,
      itemBuilder: (context, index) {
        final azkar = azkarList[index];
        final isSelected = _selectedDhikr == azkar['name'];
        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? AppColors.primaryGold.withOpacity(0.1) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isSelected
                ? const BorderSide(color: AppColors.primaryGold, width: 2)
                : BorderSide.none,
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              setState(() {
                _selectedDhikr = azkar['name']!;
                _dhikrArabic = azkar['arabic']!;
                _count = 0;
                _tabController.animateTo(0);
              });
            },
            title: Text(
              azkar['arabic']!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  azkar['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(azkar['meaning']!, style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primaryGold)
                : null,
          ),
        );
      },
    );
  }
}

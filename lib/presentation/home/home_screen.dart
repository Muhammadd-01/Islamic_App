import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/providers/user_provider.dart';
import 'package:islamic_app/presentation/prayer/prayer_provider.dart';
import 'package:islamic_app/presentation/hadith/hadith_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayerAsync = ref.watch(nextPrayerProvider);
    final dailyHadithAsync = ref.watch(dailyHadithProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Animated Background with Pattern
          _AnimatedBackground(isDark: isDark),

          // Content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Section with Date
                      _GreetingSection(ref: ref)
                          .animate()
                          .fade(duration: 500.ms)
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 28),

                      // Next Prayer Card (Hero)
                      _EnhancedPrayerCard(nextPrayerAsync: nextPrayerAsync)
                          .animate()
                          .fade(duration: 600.ms, delay: 100.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Quick Stats Row
                      _QuickStatsRow()
                          .animate()
                          .fade(duration: 500.ms, delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 28),

                      // Daily Inspiration (Hadith)
                      dailyHadithAsync.when(
                        data: (hadith) => _DailyInspirationCard(hadith: hadith)
                            .animate()
                            .fade(duration: 500.ms, delay: 300.ms)
                            .slideY(begin: 0.1, end: 0),
                        loading: () => const _ShimmerCard(height: 140),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 28),

                      // Featured Tools Section
                      _SectionHeader(
                        title: 'Featured Tools',
                        onSeeAll: () => context.push('/settings'),
                      ).animate().fade(delay: 400.ms),
                      const SizedBox(height: 16),
                      const _FeaturedToolsCarousel()
                          .animate()
                          .fade(delay: 450.ms)
                          .slideX(begin: 0.1, end: 0),

                      const SizedBox(height: 28),

                      // Quick Actions Grid
                      _SectionHeader(
                        title: 'Explore',
                      ).animate().fade(delay: 500.ms),
                      const SizedBox(height: 16),
                      _QuickActionsGrid().animate().fade(delay: 550.ms),

                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mosque, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Islamic App',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.notifications_outlined, size: 20),
          ),
          onPressed: () => context.push('/notifications'),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.person_outline, size: 20),
          ),
          onPressed: () => context.push('/profile'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// Animated Background with Islamic Pattern
class _AnimatedBackground extends StatelessWidget {
  final bool isDark;

  const _AnimatedBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.backgroundDark, AppColors.surfaceDark]
                  : [
                      AppColors.backgroundLight,
                      AppColors.primary.withValues(alpha: 0.03),
                    ],
            ),
          ),
        ),

        // Animated circles
        Positioned(
          top: -80,
          right: -80,
          child:
              Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 5.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                  ),
        ),

        Positioned(
          bottom: 200,
          left: -100,
          child:
              Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.1),
                          AppColors.secondary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 6.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                  ),
        ),

        // Decorative pattern overlay
        Positioned(
          top: 0,
          right: 0,
          child: Opacity(
            opacity: isDark ? 0.03 : 0.05,
            child: Transform.rotate(
              angle: math.pi / 6,
              child: const Icon(
                Icons.star_border,
                size: 300,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Greeting Section with Date
class _GreetingSection extends StatelessWidget {
  final WidgetRef ref;

  const _GreetingSection({required this.ref});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getIslamicGreeting() {
    return 'السلام عليكم';
  }

  @override
  Widget build(BuildContext context) {
    final userProfileStream = ref.watch(userProfileStreamProvider);

    return userProfileStream.when(
      data: (snapshot) {
        final userData = snapshot.data() as Map<String, dynamic>?;
        final userName = userData?['name'] ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getIslamicGreeting(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(width: 8),
                Text(
                  _getGreeting(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        );
      },
      loading: () => _buildDefaultGreeting(context),
      error: (_, __) => _buildDefaultGreeting(context),
    );
  }

  Widget _buildDefaultGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _getIslamicGreeting(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text('•', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(width: 8),
            Text(
              _getGreeting(),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Welcome',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// Enhanced Prayer Card
class _EnhancedPrayerCard extends StatelessWidget {
  final AsyncValue<String> nextPrayerAsync;

  const _EnhancedPrayerCard({required this.nextPrayerAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  Color(0xFF00897B),
                  Color(0xFF00695C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time_filled,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Next Prayer',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Maghrib',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '6:45 PM',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.nights_stay,
                            color: Colors.white,
                            size: 36,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          duration: 2.seconds,
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                        ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: AppColors.neonGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Time Remaining:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 10),
                      nextPrayerAsync.when(
                        data: (time) => Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.neonGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        loading: () => const CupertinoActivityIndicator(
                          color: Colors.white,
                        ),
                        error: (_, __) => const Text(
                          '--:--:--',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

// Quick Stats Row
class _QuickStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            value: '7',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.menu_book,
            iconColor: AppColors.primary,
            value: 'Pg 45',
            label: 'Last Read',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            value: '4/5',
            label: 'Prayers',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// Daily Inspiration Card
class _DailyInspirationCard extends StatelessWidget {
  final Map<String, dynamic> hadith;

  const _DailyInspirationCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Inspiration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Hadith of the Day',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '"${hadith['text_en']}"',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${hadith['narrator']}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }
}

// Featured Tools Carousel
class _FeaturedToolsCarousel extends StatelessWidget {
  const _FeaturedToolsCarousel();

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolData(
        'Tasbeeh',
        Icons.fingerprint,
        const Color(0xFF0D9488),
        '/tasbeeh',
      ),
      _ToolData('Qibla', Icons.explore, const Color(0xFFF97316), '/qibla'),
      _ToolData('99 Names', Icons.stars, const Color(0xFF8B5CF6), '/names'),
      _ToolData(
        'Audio',
        Icons.headphones,
        const Color(0xFF3B82F6),
        '/reciters',
      ),
      _ToolData('Courses', Icons.school, const Color(0xFFEC4899), '/courses'),
    ];

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final tool = tools[index];
          return _GlassmorphicToolCard(
            title: tool.title,
            icon: tool.icon,
            color: tool.color,
            onTap: () => context.push(tool.route),
          );
        },
      ),
    );
  }
}

class _ToolData {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _ToolData(this.title, this.icon, this.color, this.route);
}

class _GlassmorphicToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GlassmorphicToolCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Actions Grid
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('Quran', Icons.book, const Color(0xFF10B981), '/quran'),
      _ActionData(
        'Hadith',
        Icons.menu_book,
        const Color(0xFF3B82F6),
        '/hadith',
      ),
      _ActionData(
        'Dua',
        Icons.volunteer_activism,
        const Color(0xFFEC4899),
        '/duas',
      ),
      _ActionData(
        'Calendar',
        Icons.calendar_month,
        const Color(0xFF14B8A6),
        '/calendar',
      ),
      _ActionData(
        'Q&A',
        Icons.chat_bubble_outline,
        const Color(0xFF8B5CF6),
        '/qa',
      ),
      _ActionData(
        'Scholars',
        Icons.school,
        const Color(0xFF7C3AED),
        '/scholars',
      ),
      _ActionData(
        'Library',
        Icons.library_books,
        const Color(0xFFEA580C),
        '/library',
      ),
      _ActionData(
        'Religions',
        Icons.balance,
        const Color(0xFF6366F1),
        '/study-religions',
      ),
      _ActionData(
        'Debate',
        Icons.forum,
        const Color(0xFFEF4444),
        '/debate-panel',
      ),
      _ActionData(
        'Settings',
        Icons.settings,
        const Color(0xFF6B7280),
        '/settings',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionItem(
          icon: action.icon,
          label: action.label,
          color: action.color,
          onTap: () => context.push(action.route),
        ).animate(delay: (50 * index).ms).fade().scale();
      },
    );
  }
}

class _ActionData {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  _ActionData(this.label, this.icon, this.color, this.route);
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Shimmer Loading Card
class _ShimmerCard extends StatelessWidget {
  final double height;

  const _ShimmerCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.1));
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0.7),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        title: const Text('Islamic App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child:
                Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      duration: 4.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                    ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                _buildGreetingSection(
                  context,
                  ref,
                ).animate().fade().slideX(begin: -0.2, end: 0),

                const SizedBox(height: 24),

                // Daily Inspiration (Hadith)
                dailyHadithAsync.when(
                  data: (hadith) => _DailyInspirationCard(hadith: hadith),
                  loading: () => const _LoadingCard(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Next Prayer Card (Hero)
                _NextPrayerCard(nextPrayerAsync: nextPrayerAsync),

                const SizedBox(height: 24),

                // Featured Tools
                const Text(
                  'Featured Tools',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).animate().fade(delay: 300.ms),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FeaturedToolCard(
                        title: 'Tasbeeh',
                        icon: Icons.fingerprint,
                        color: Colors.teal,
                        onTap: () => context.push('/tasbeeh'),
                      ),
                      const SizedBox(width: 16),
                      _FeaturedToolCard(
                        title: 'Qibla',
                        icon: Icons.explore,
                        color: Colors.orange,
                        onTap: () => context.push('/qibla'),
                      ),
                      const SizedBox(width: 16),
                      _FeaturedToolCard(
                        title: '99 Names',
                        icon: Icons.stars,
                        color: Colors.purple,
                        onTap: () => context.push('/names'),
                      ),
                      const SizedBox(width: 16),
                      _FeaturedToolCard(
                        title: 'Courses',
                        icon: Icons.school_outlined,
                        color: Colors.blue,
                        onTap: () => context.push('/courses'),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 400.ms).slideX(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Quick Actions Grid
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).animate().fade(delay: 500.ms),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _QuickAction(
                      icon: Icons.book,
                      label: 'Quran',
                      color: const Color(0xFF10B981),
                      onTap: () => context.go('/quran'),
                    ),
                    _QuickAction(
                      icon: Icons.menu_book,
                      label: 'Hadith',
                      color: const Color(0xFF3B82F6),
                      onTap: () => context.push('/hadith'),
                    ),
                    _QuickAction(
                      icon: Icons.volunteer_activism,
                      label: 'Dua',
                      color: const Color(0xFFEC4899),
                      onTap: () => context.push('/duas'),
                    ),
                    _QuickAction(
                      icon: Icons.calendar_month,
                      label: 'Calendar',
                      color: const Color(0xFF10B981),
                      onTap: () => context.push('/calendar'),
                    ),
                    _QuickAction(
                      icon: Icons.chat_bubble_outline,
                      label: 'Q&A',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => context.go('/qa'),
                    ),
                    _QuickAction(
                      icon: Icons.school,
                      label: 'Scholars',
                      color: const Color(0xFF7C3AED),
                      onTap: () => context.push('/scholars'),
                    ),
                    _QuickAction(
                      icon: Icons.library_books,
                      label: 'Library',
                      color: const Color(0xFFEA580C),
                      onTap: () => context.push('/library'),
                    ),
                    _QuickAction(
                      icon: Icons.balance,
                      label: 'Religions',
                      color: Colors.indigo,
                      onTap: () => context.push('/study-religions'),
                    ),
                    _QuickAction(
                      icon: Icons.forum_outlined,
                      label: 'Debate',
                      color: Colors.deepOrange,
                      onTap: () => context.push('/debate-panel'),
                    ),
                    _QuickAction(
                      icon: Icons.settings,
                      label: 'Settings',
                      color: Colors.grey,
                      onTap: () => context.push('/settings'),
                    ),
                  ].animate(interval: 50.ms).fade().scale(),
                ),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context, WidgetRef ref) {
    final userProfileStream = ref.watch(userProfileStreamProvider);

    return userProfileStream.when(
      data: (snapshot) {
        final userData = snapshot.data() as Map<String, dynamic>?;
        final userName = userData?['name'] ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assalamu Alaikum 👋',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assalamu Alaikum 👋',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          const Text(
            'User',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assalamu Alaikum 👋',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          const Text(
            'User',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _DailyInspirationCard extends StatelessWidget {
  final Map<String, dynamic> hadith;

  const _DailyInspirationCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.accent),
              const SizedBox(width: 8),
              const Text(
                'Daily Inspiration',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${hadith['text_en']}"',
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Text(
            '- ${hadith['narrator']}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: -0.2, end: 0, duration: 500.ms);
  }
}

class _NextPrayerCard extends StatelessWidget {
  final AsyncValue<String> nextPrayerAsync;

  const _NextPrayerCard({required this.nextPrayerAsync});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF00695C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: AppColors.neonGreen.withValues(
                                  alpha: 0.8,
                                ),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Next Prayer',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Maghrib', // This should ideally be dynamic too
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.nights_stay_outlined,
                        color: AppColors.neonBlue,
                        size: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Time Remaining:',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        nextPrayerAsync.when(
                          data: (time) => Text(
                            time,
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          loading: () => const Text(
                            'Loading...',
                            style: TextStyle(color: Colors.white),
                          ),
                          error: (_, __) => const Text(
                            '--:--',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fade(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
  }
}

class _FeaturedToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeaturedToolCard({
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
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
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms);
  }
}

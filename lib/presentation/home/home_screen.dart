import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/prayer/prayer_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayerAsync = ref.watch(nextPrayerProvider);

    return Scaffold(
      appBar: AppBar(
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
          IconButton(
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
            onPressed: () {
              context.push('/login');
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting & Date
            Text(
              'Assalamu Alaikum,',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const Text(
              'Muhammad',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Next Prayer Card
            ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            Color(0xFF00695C), // Teal-ish
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
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
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Maghrib',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.nights_stay_outlined,
                                  color: AppColors.neonBlue,
                                  size: 28,
                                ),
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
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                nextPrayerAsync.when(
                                  data: (time) => Text(
                                    time,
                                    style: const TextStyle(
                                      color: AppColors.neonGreen,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
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
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),

            const SizedBox(height: 24),

            // Featured Section
            const Text(
              'Featured',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FeaturedCard(
                    title: 'Riyad as-Salihin',
                    subtitle: 'Book of Virtues',
                    imageColor: Colors.blueAccent,
                    icon: Icons.menu_book,
                    onTap: () => context.push('/library'),
                  ),
                  const SizedBox(width: 16),
                  _FeaturedCard(
                    title: 'Dr. Omar Suleiman',
                    subtitle: 'Scholar of the Week',
                    imageColor: Colors.purpleAccent,
                    icon: Icons.person,
                    onTap: () => context.push('/scholars'),
                  ),
                  const SizedBox(width: 16),
                  _FeaturedCard(
                    title: 'Islamic Finance',
                    subtitle: 'New Course Available',
                    imageColor: Colors.teal,
                    icon: Icons.school,
                    onTap: () => context.push('/courses'),
                  ),
                ],
              ),
            ).animate().fade().slideX(begin: 0.1, end: 0, delay: 200.ms),

            const SizedBox(height: 24),

            // Quick Actions Grid
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children:
                  [
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
                          icon: Icons.article,
                          label: 'Articles',
                          color: const Color(0xFFF59E0B),
                          onTap: () => context.push('/articles'),
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
                          icon: Icons.access_time_filled,
                          label: 'Prayer',
                          color: Colors.orange,
                          onTap: () => context.go('/prayer'),
                        ),
                        _QuickAction(
                          icon: Icons.fingerprint,
                          label: 'Tasbeeh',
                          color: Colors.teal,
                          onTap: () => context.go('/tasbeeh'),
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
                          icon: Icons.school_outlined,
                          label: 'Courses',
                          color: const Color(0xFF059669),
                          onTap: () => context.push('/courses'),
                        ),
                        _QuickAction(
                          icon: Icons.settings,
                          label: 'Settings',
                          color: Colors.grey,
                          onTap: () => context.push('/settings'),
                        ),
                      ]
                      .animate(interval: 50.ms)
                      .fade()
                      .scale(curve: Curves.easeOutBack),
            ),

            const SizedBox(height: 24),

            // Daily Dua Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
                  const Text(
                    '"The best among you is the one who learns the Quran and teaches it."',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '- Sahih Al-Bukhari',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ).animate().fade().slideX(begin: 0.1, end: 0, delay: 200.ms),
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

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color imageColor;
  final IconData icon;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.imageColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [imageColor, imageColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: imageColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Featured',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
            onPressed: () {},
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Prayer',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Maghrib',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.nights_stay_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  nextPrayerAsync.when(
                    data: (time) => Text(
                      '- $time',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    loading: () => const Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    ),
                    error: (_, __) => const Text(
                      '--:--:--',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.2, end: 0),

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
                  icon: Icons.volunteer_activism,
                  label: 'Dua',
                  color: Colors.purple,
                  onTap: () {}, // TODO: Implement Dua
                ),
                _QuickAction(
                  icon: Icons.fingerprint,
                  label: 'Tasbeeh',
                  color: Colors.teal,
                  onTap: () => context.go('/tasbeeh'),
                ),
                _QuickAction(
                  icon: Icons.menu_book,
                  label: 'Hadith',
                  color: Colors.brown,
                  onTap: () {}, // TODO: Implement Hadith
                ),
                _QuickAction(
                  icon: Icons.article,
                  label: 'Articles',
                  color: Colors.indigo,
                  onTap: () {}, // TODO: Implement Articles
                ),
                _QuickAction(
                  icon: Icons.settings,
                  label: 'Settings',
                  color: Colors.grey,
                  onTap: () {},
                ),
              ],
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

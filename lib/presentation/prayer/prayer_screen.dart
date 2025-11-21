import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/prayer/prayer_provider.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final countdownAsync = ref.watch(nextPrayerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Countdown Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Maghrib',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  countdownAsync.when(
                    data: (time) => Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
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
                  const SizedBox(height: 8),
                  const Text(
                    'Mock Location, City',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ).animate().fade().scale(),

            const SizedBox(height: 24),

            // Prayer Times List
            prayerTimesAsync.when(
              data: (times) => Column(
                children: [
                  _PrayerRow(
                    name: 'Fajr',
                    time: times['fajr'],
                    icon: Icons.wb_twilight,
                  ),
                  _PrayerRow(
                    name: 'Dhuhr',
                    time: times['dhuhr'],
                    icon: Icons.wb_sunny,
                  ),
                  _PrayerRow(
                    name: 'Asr',
                    time: times['asr'],
                    icon: Icons.wb_sunny_outlined,
                  ),
                  _PrayerRow(
                    name: 'Maghrib',
                    time: times['maghrib'],
                    icon: Icons.nights_stay_outlined,
                  ),
                  _PrayerRow(
                    name: 'Isha',
                    time: times['isha'],
                    icon: Icons.nights_stay,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),

            const SizedBox(height: 24),

            // Qibla Compass (Visual Only)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'Qibla Direction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                      ),
                      const Icon(
                            Icons.navigation,
                            size: 48,
                            color: AppColors.primary,
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .rotate(
                            duration: 3.seconds,
                            begin: 0,
                            end: 0.1,
                            curve: Curves.easeInOutSine,
                          )
                          .then()
                          .rotate(
                            duration: 3.seconds,
                            begin: 0.1,
                            end: 0,
                            curve: Curves.easeInOutSine,
                          ),
                      const Positioned(
                        top: 10,
                        child: Text(
                          'N',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Kaaba is 45° from North'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;

  const _PrayerRow({
    required this.name,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            time,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate().fade().slideX(begin: -0.1, end: 0);
  }
}

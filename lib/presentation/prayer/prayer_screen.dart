import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/prayer/prayer_provider.dart';
import 'package:islamic_app/presentation/prayer/prayer_tracker_provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen>
    with SingleTickerProviderStateMixin {
  double _lastHeading = 0.0;
  bool _hasHapticTriggered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final countdownAsync = ref.watch(nextPrayerProvider);
    final qiblaAsync = ref.watch(qiblaDirectionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Prayer History',
            onPressed: () => context.push('/prayer-history'),
          ),
        ],
      ),
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
                    'Next Prayer',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  prayerTimesAsync.when(
                    data: (times) => Text(
                      _getNextPrayerName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    loading: () => const Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    ),
                    error: (_, __) => const Text(
                      'Maghrib',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
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
                    time: times['Fajr'] ?? times['fajr'] ?? '--:--',
                    icon: Icons.wb_twilight,
                  ),
                  _PrayerRow(
                    name: DateTime.now().weekday == DateTime.friday
                        ? 'Jummah'
                        : 'Dhuhr',
                    time:
                        times['Dhuhr'] ??
                        times['dhuhr'] ??
                        times['Jummah'] ??
                        times['jummah'] ??
                        '--:--',
                    icon: Icons.wb_sunny,
                  ),
                  _PrayerRow(
                    name: 'Asr',
                    time: times['Asr'] ?? times['asr'] ?? '--:--',
                    icon: Icons.wb_sunny_outlined,
                  ),
                  _PrayerRow(
                    name: 'Maghrib',
                    time: times['Maghrib'] ?? times['maghrib'] ?? '--:--',
                    icon: Icons.nights_stay_outlined,
                  ),
                  _PrayerRow(
                    name: 'Isha',
                    time: times['Isha'] ?? times['isha'] ?? '--:--',
                    icon: Icons.nights_stay,
                  ),
                ],
              ),
              loading: () => Column(
                children: List.generate(
                  5,
                  (index) =>
                      Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            height: 64,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(
                            duration: 1200.ms,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                ),
              ),
              error: (err, stack) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to load prayer times',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your internet connection',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.refresh(prayerTimesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Qibla Compass
            qiblaAsync.when(
              data: (qiblaDirection) =>
                  _buildEnhancedCompass(context, qiblaDirection, isDark),
              loading: () => _buildLoadingState(context),
              error: (err, stack) => _buildErrorState(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCompass(
    BuildContext context,
    double qiblaDirection,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return _buildCompassError(context, 'Compass error');
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final compassEvent = snapshot.data!;
          final heading = compassEvent.heading;

          if (heading == null) {
            return _buildCompassError(context, 'Compass sensor not found');
          }

          // Smoothing logic
          _lastHeading = ui.lerpDouble(_lastHeading, heading, 0.15) ?? heading;

          final isFacingQibla =
              (qiblaDirection - _lastHeading).abs() < 2 ||
              (360 - (qiblaDirection - _lastHeading).abs()) < 2;

          // Haptic feedback logic
          if (isFacingQibla && !_hasHapticTriggered) {
            HapticFeedback.mediumImpact();
            _hasHapticTriggered = true;
          } else if (!isFacingQibla) {
            _hasHapticTriggered = false;
          }

          return Column(
            children: [
              _buildCompassHeader(qiblaDirection, isFacingQibla),
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(280, 280),
                    painter: CompassRingPainter(
                      isDark: isDark,
                      isAligned: isFacingQibla,
                    ),
                  ),
                  // Rotating Compass Plate
                  AnimatedRotation(
                    turns: -_lastHeading / 360,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear,
                    child: _buildCardinals(isDark),
                  ),
                  // Fixed Qibla Needle (it rotates relative to the compass plate)
                  AnimatedRotation(
                    turns: (qiblaDirection - _lastHeading) / 360,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear,
                    child: _buildQiblaNeedle(isFacingQibla),
                  ),
                  _buildCenterLogo(isDark),
                ],
              ),
              const SizedBox(height: 32),
              _buildStatusIndicator(isFacingQibla, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompassHeader(double qiblaDirection, bool isFacingQibla) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Qibla Finder',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isFacingQibla
                ? Colors.green.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isFacingQibla ? 'ALIGNED' : '${qiblaDirection.toStringAsFixed(1)}°',
            style: TextStyle(
              color: isFacingQibla ? Colors.green : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardinals(bool isDark) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white70 : Colors.black54,
    );
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text('N', style: style.copyWith(color: Colors.red)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text('S', style: style),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('W', style: style),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('E', style: style),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaNeedle(bool isFacingQibla) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          size: 40,
          color: isFacingQibla ? Colors.green : AppColors.primary,
        ),
        const SizedBox(height: 140), // Offset to space it out from center
      ],
    );
  }

  Widget _buildCenterLogo(bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/deensphere_logo.png'),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isFacingQibla, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isFacingQibla
            ? Colors.green.withValues(alpha: 0.1)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFacingQibla ? Icons.check_circle : Icons.explore_outlined,
            color: isFacingQibla ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            isFacingQibla ? "You're facing the Kaaba" : "Rotate to find Qibla",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFacingQibla ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.location_off, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('Location access required for Qibla'),
          TextButton(
            onPressed: () => ref.refresh(qiblaDirectionProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getNextPrayerName() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 0 && hour < 5) return 'Fajr';
    if (hour >= 5 && hour < 12)
      return now.weekday == DateTime.friday ? 'Jummah' : 'Dhuhr';
    if (hour >= 12 && hour < 16) return 'Asr';
    if (hour >= 16 && hour < 19) return 'Maghrib';
    return 'Isha';
  }

  Widget _buildCompassError(BuildContext context, String message) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          Text(message),
        ],
      ),
    );
  }
}

class _PrayerRow extends ConsumerWidget {
  final String name;
  final String time;
  final IconData icon;

  const _PrayerRow({
    required this.name,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ref.watch(isPrayerCompleteProvider(name));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5)
            : null,
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.green : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.green[700]
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Tracking Checkbox
          GestureDetector(
            onTap: () async {
              try {
                final toggle = ref.read(togglePrayerProvider);
                await toggle(name);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : (isDark ? Colors.grey[700] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
                border: !isCompleted
                    ? Border.all(color: Colors.grey[400]!, width: 1.5)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    ).animate().fade().slideX(begin: -0.1, end: 0);
  }
}

class CompassRingPainter extends CustomPainter {
  final bool isDark;
  final bool isAligned;

  CompassRingPainter({required this.isDark, required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1);

    // Draw main circle
    canvas.drawCircle(center, radius, paint);

    // Draw glow if aligned
    if (isAligned) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..color = Colors.green.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius, glowPaint);
    }

    // Draw ticks
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < 360; i += 10) {
      final angle = (i - 90) * (math.pi / 180);
      final isMajor = i % 90 == 0;
      final length = isMajor ? 15.0 : 8.0;

      tickPaint.color = isMajor
          ? (isDark ? Colors.white38 : Colors.black38)
          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1));

      final p1 = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - 5 - length) * math.cos(angle),
        center.dy + (radius - 5 - length) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

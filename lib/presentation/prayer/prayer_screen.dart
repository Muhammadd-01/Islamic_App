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
            Consumer(
              builder: (context, ref, child) {
                final displayInfoAsync = ref.watch(prayerDisplayInfoProvider);

                return displayInfoAsync.when(
                  data: (info) {
                    final currentName = info['currentName'] ?? 'Isha';
                    final nextName = info['nextName'] ?? 'Fajr';
                    final progress =
                        double.tryParse(info['progress'] ?? '0.0') ?? 0.0;

                    final currentColors = _getCardColors(currentName);
                    final nextColors = _getCardColors(nextName);
                    final gradientColors = _interpolateGradients(
                      currentColors,
                      nextColors,
                      progress,
                    );

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getPrayerIcon(currentName),
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CURRENT PRAYER',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            info['currentRemaining'] ?? '--:--:--',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Started at ${info['currentStartTime'] ?? '--:--'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => _buildErrorCard(),
                );
              },
            ).animate().fade().scale(
              begin: const Offset(0.95, 0.95),
              duration: 400.ms,
            ),

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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
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
          final accuracy = compassEvent.accuracy;

          if (heading == null) {
            return _buildCompassError(context, 'Compass sensor not found');
          }

          // Stable Smoothing logic (handling 0/360 wrap)
          _lastHeading = _lerpAngle(_lastHeading, heading, 0.15);

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

          final isLowAccuracy = accuracy != null && accuracy < 15;

          return Column(
            children: [
              _buildCompassHeader(context, ref, qiblaDirection, isFacingQibla),
              const SizedBox(height: 12),
              _buildAccuracyStatus(qiblaDirection, accuracy, isLowAccuracy),
              const SizedBox(height: 20),
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
                  // Rotating Compass Plate - Using Transform.rotate for smooth sensor-driven updates
                  Transform.rotate(
                    angle: -_lastHeading * (math.pi / 180),
                    child: _buildCardinals(isDark),
                  ),
                  // Fixed Qibla Needle (it rotates relative to the compass plate)
                  Transform.rotate(
                    angle: (qiblaDirection - _lastHeading) * (math.pi / 180),
                    child: CustomPaint(
                      size: const Size(200, 200),
                      painter: QiblaNeedlePainter(isAligned: isFacingQibla),
                    ),
                  ),
                  // Center Point
                  _buildCenterLogo(isDark),
                  // Kaaba Indicator on the ring
                  Transform.rotate(
                    angle: (qiblaDirection - _lastHeading) * (math.pi / 180),
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.square,
                                size: 12,
                                color: isFacingQibla
                                    ? Colors.green
                                    : AppColors.primaryGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildCompassHeader(
    BuildContext context,
    WidgetRef ref,
    double qiblaDirection,
    bool isFacingQibla,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Qibla Finder',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                ref.invalidate(qiblaDirectionProvider);
                HapticFeedback.lightImpact();
              },
              icon: const Icon(Icons.my_location, size: 20),
              tooltip: 'Refresh Location',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isFacingQibla
                    ? Colors.green.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isFacingQibla
                    ? 'ALIGNED'
                    : '${qiblaDirection.toStringAsFixed(1)}°',
                style: TextStyle(
                  color: isFacingQibla ? Colors.green : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccuracyStatus(
    double qiblaDirection,
    double? accuracy,
    bool isLowAccuracy,
  ) {
    bool isStale = qiblaDirection == 0.0;
    Color statusColor = isStale
        ? Colors.orange
        : (isLowAccuracy ? Colors.amber : Colors.blue);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isStale
                    ? Icons.warning_amber_rounded
                    : (isLowAccuracy ? Icons.sync_problem : Icons.gps_fixed),
                size: 14,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                isStale
                    ? 'Waiting for precise location...'
                    : (isLowAccuracy
                          ? 'Low sensor accuracy'
                          : 'High-precision tracking active'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        if (isLowAccuracy && !isStale) ...[
          const SizedBox(height: 8),
          Text(
            'Calibrate: Move phone in a figure-8 motion',
            style: TextStyle(
              fontSize: 10,
              color: Colors.amber.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  /// Helper to interpolate angles correctly across the 0/360 boundary
  double _lerpAngle(double start, double end, double t) {
    double diff = end - start;
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }
    return (start + diff * t) % 360;
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: isFacingQibla
            ? LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.2),
                  Colors.green.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: !isFacingQibla
            ? (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05))
            : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFacingQibla
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFacingQibla ? Icons.verified : Icons.explore_outlined,
            color: isFacingQibla ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            isFacingQibla ? "YOU ARE FACING THE KAABA" : "ROTATE TO FIND QIBLA",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
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

  List<Color> _getCardColors(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return const [Color(0xFF4C1D95), Color(0xFF6366F1), Color(0xFF818CF8)];
      case 'Dhuhr':
      case 'Jummah':
        return const [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFD97706)];
      case 'Asr':
        return const [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFD97706)];
      case 'Maghrib':
        return const [Color(0xFFDC2626), Color(0xFFEA580C), Color(0xFF7C3AED)];
      case 'Isha':
      default:
        return const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4C1D95)];
    }
  }

  List<Color> _interpolateGradients(
    List<Color> current,
    List<Color> next,
    double progress,
  ) {
    if (current.length != next.length) return current;
    return List.generate(current.length, (i) {
      return Color.lerp(current[i], next[i], progress)!;
    });
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white24),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Center(
        child: Text(
          'Error loading prayer times',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
      case 'Jummah':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.sunny_snowing;
      case 'Maghrib':
        return Icons.nights_stay_outlined;
      case 'Isha':
      default:
        return Icons.nights_stay;
    }
  }

  Widget _buildCompassError(BuildContext context, String message) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
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

  List<Color> _getPrayerColors(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return const [Color(0xFF4C1D95), Color(0xFF6366F1)];
      case 'Dhuhr':
      case 'Jummah':
        return const [Color(0xFFF59E0B), Color(0xFFFBBF24)];
      case 'Asr':
        return const [Color(0xFFEA580C), Color(0xFFF97316)];
      case 'Maghrib':
        return const [Color(0xFFDC2626), Color(0xFFEA580C)];
      case 'Isha':
      default:
        return const [Color(0xFF1E1B4B), Color(0xFF312E81)];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ref.watch(isPrayerCompleteProvider(name));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getPrayerColors(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored side bar
              Container(
                width: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors[0].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: colors[0], size: 22),
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
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
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
                                SnackBar(
                                  content: Text('Failed to update: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: isCompleted
                                ? LinearGradient(colors: colors)
                                : null,
                            color: isCompleted
                                ? null
                                : (isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(10),
                            border: !isCompleted
                                ? Border.all(
                                    color: isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                    width: 1.5,
                                  )
                                : null,
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: colors[0].withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade().slideX(begin: -0.05, end: 0);
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

    // Background circle
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.black.withValues(alpha: 0.02);
    canvas.drawCircle(center, radius, bgPaint);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = isDark ? Colors.white12 : Colors.black12;

    // Draw main circle
    canvas.drawCircle(center, radius, paint);

    // Draw secondary inner circle
    canvas.drawCircle(center, radius * 0.8, paint);

    // Draw glow if aligned
    if (isAligned) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..color = Colors.green.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius, glowPaint);
    }

    // Draw ticks
    final tickPaint = Paint()..style = PaintingStyle.stroke;

    for (var i = 0; i < 360; i += 2) {
      final angle = (i - 90) * (math.pi / 180);
      final isMajor = i % 30 == 0;
      final isMinor = i % 10 == 0;

      double length = 0;
      if (isMajor)
        length = 12.0;
      else if (isMinor)
        length = 6.0;
      else if (isAligned && i % 4 == 0)
        length = 2.0;

      if (length > 0) {
        tickPaint.strokeWidth = isMajor ? 2.0 : 1.0;
        tickPaint.color = isMajor
            ? (isDark ? Colors.white54 : Colors.black54)
            : (isDark ? Colors.white12 : Colors.black12);

        if (isAligned) {
          tickPaint.color = Colors.green.withValues(alpha: 0.5);
        }

        final p1 = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        final p2 = Offset(
          center.dx + (radius - length) * math.cos(angle),
          center.dy + (radius - length) * math.sin(angle),
        );
        canvas.drawLine(p1, p2, tickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class QiblaNeedlePainter extends CustomPainter {
  final bool isAligned;

  QiblaNeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isAligned ? Colors.green : AppColors.primaryGold;

    final path = Path();

    // Needle pointing UP
    // Top point
    path.moveTo(center.dx, center.dy - radius * 0.9);
    // Right point
    path.lineTo(center.dx + 12, center.dy);
    // Bottom point
    path.lineTo(center.dx, center.dy + 15);
    // Left point
    path.lineTo(center.dx - 12, center.dy);
    path.close();

    // Add a subtle shadow
    canvas.drawShadow(path, Colors.black, 4, true);
    canvas.drawPath(path, paint);

    // Add a second color for the "bottom" half of the needle
    final bottomPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isAligned ? Colors.green.shade800 : Colors.orange.shade900;

    final bottomPath = Path();
    bottomPath.moveTo(center.dx, center.dy);
    bottomPath.lineTo(center.dx + 12, center.dy);
    bottomPath.lineTo(center.dx, center.dy + 15);
    bottomPath.lineTo(center.dx - 12, center.dy);
    bottomPath.close();
    canvas.drawPath(bottomPath, bottomPaint);

    // Draw a small circle in the middle of the needle
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

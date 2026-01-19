import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/prayer/prayer_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _heading = 0;
  double _smoothHeading = 0;
  bool _hasCompass = true;
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initCompass();
  }

  Future<void> _initCompass() async {
    setState(() => _isLoading = true);

    // Check for sensor permission on Android
    if (Platform.isAndroid) {
      final status = await Permission.sensors.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Try location permission as fallback for compass
        final locationStatus = await Permission.locationWhenInUse.request();
        _hasPermission = locationStatus.isGranted;
      } else {
        _hasPermission = true;
      }
    } else {
      _hasPermission = true;
    }

    // Check if device has compass
    try {
      final event = await FlutterCompass.events?.first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('Compass not available'),
      );

      if (event == null || event.heading == null) {
        setState(() {
          _hasCompass = false;
          _errorMessage = 'Compass sensor not detected on this device';
          _isLoading = false;
        });
        return;
      }

      _hasCompass = true;
    } catch (e) {
      setState(() {
        _hasCompass = false;
        _errorMessage =
            'Compass not available. Please ensure your device has a magnetometer.';
        _isLoading = false;
      });
      return;
    }

    // Start listening to compass events
    _startCompass();
  }

  void _startCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        if (!mounted) return;

        if (event.heading != null) {
          setState(() {
            _heading = event.heading!;
            // Smooth the heading to prevent jitter
            _smoothHeading = _lerpAngle(_smoothHeading, _heading, 0.15);
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _hasCompass = false;
            _errorMessage = 'Compass error: $error';
            _isLoading = false;
          });
        }
      },
    );
  }

  // Smooth angle interpolation
  double _lerpAngle(double current, double target, double t) {
    double diff = target - current;

    // Normalize to -180 to 180
    while (diff > 180) diff -= 360;
    while (diff < -180) diff += 360;

    return current + diff * t;
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaAsync = ref.watch(qiblaDirectionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initCompass,
            tooltip: 'Recalibrate',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : !_hasCompass
          ? _buildNoCompassState()
          : qiblaAsync.when(
              data: (qiblaDirection) => _buildCompass(qiblaDirection, isDark),
              loading: () => _buildLoadingState(),
              error: (e, s) => _buildErrorState(e.toString()),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryGold),
          const SizedBox(height: 20),
          Text(
            'Initializing compass...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCompassState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Compass Not Available',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'This device does not have a compass sensor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tips:\n• Move away from magnetic objects\n• Calibrate by moving in a figure-8 pattern\n• Restart the app after calibration',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initCompass,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(qiblaDirectionProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(double qiblaDirection, bool isDark) {
    // Calculate the angle for the Qibla arrow
    final qiblaAngle = (qiblaDirection - _smoothHeading) * (math.pi / 180);

    // Check if pointing to Qibla (within 5 degrees)
    final isPointingToQibla =
        (qiblaDirection - _smoothHeading).abs() < 5 ||
        (qiblaDirection - _smoothHeading).abs() > 355;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Heading info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Heading: ${_smoothHeading.toStringAsFixed(0)}°',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Icon(Icons.mosque, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Qibla: ${qiblaDirection.toStringAsFixed(0)}°',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ).animate().fade().slideY(begin: -0.2, end: 0),

          const SizedBox(height: 40),

          // Compass with Qibla
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow when pointing to Qibla
              if (isPointingToQibla)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 320 + (_pulseController.value * 20),
                      height: 320 + (_pulseController.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withValues(
                          alpha: 0.1 + _pulseController.value * 0.1,
                        ),
                      ),
                    );
                  },
                ),

              // Compass background
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [Colors.grey.shade800, Colors.grey.shade900]
                        : [Colors.white, Colors.grey.shade200],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isPointingToQibla
                                  ? Colors.green
                                  : AppColors.primaryGold)
                              .withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: -_smoothHeading * (math.pi / 180),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Direction markers
                      ...['N', 'E', 'S', 'W'].asMap().entries.map((e) {
                        final angle = e.key * 90 * (math.pi / 180);
                        return Transform.translate(
                          offset: Offset(
                            115 * math.sin(angle),
                            -115 * math.cos(angle),
                          ),
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: e.value == 'N' ? 24 : 18,
                              fontWeight: e.value == 'N'
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: e.value == 'N' ? Colors.red : Colors.grey,
                            ),
                          ),
                        );
                      }),

                      // Compass lines
                      CustomPaint(
                        size: const Size(280, 280),
                        painter: _CompassLinesPainter(isDark: isDark),
                      ),
                    ],
                  ),
                ),
              ),

              // Qibla arrow (fixed direction)
              Transform.rotate(
                angle: qiblaAngle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPointingToQibla
                            ? Colors.green
                            : AppColors.primaryGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mosque,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isPointingToQibla
                            ? Colors.green
                            : AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              // Center point
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Status message
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPointingToQibla
                  ? Colors.green.withValues(alpha: 0.15)
                  : AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPointingToQibla
                    ? Colors.green.withValues(alpha: 0.3)
                    : AppColors.primaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPointingToQibla ? Icons.check_circle : Icons.explore,
                  color: isPointingToQibla
                      ? Colors.green
                      : AppColors.primaryGold,
                ),
                const SizedBox(width: 12),
                Text(
                  isPointingToQibla
                      ? 'You are facing the Qibla!'
                      : 'Rotate to align with Qibla',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isPointingToQibla
                        ? Colors.green
                        : AppColors.primaryGold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calibration note
          Text(
            'Tip: Move your phone in a figure-8 pattern to calibrate',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _CompassLinesPainter extends CustomPainter {
  final bool isDark;

  _CompassLinesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = isDark ? Colors.grey.shade700 : Colors.grey.shade300
      ..strokeWidth = 1;

    for (int i = 0; i < 72; i++) {
      final angle = i * 5 * (math.pi / 180);
      final isMainDirection = i % 18 == 0;
      final isMedium = i % 9 == 0;

      final outerRadius = size.width / 2 - 10;
      final innerRadius = isMainDirection
          ? size.width / 2 - 30
          : isMedium
          ? size.width / 2 - 20
          : size.width / 2 - 15;

      final start = Offset(
        center.dx + innerRadius * math.sin(angle),
        center.dy - innerRadius * math.cos(angle),
      );
      final end = Offset(
        center.dx + outerRadius * math.sin(angle),
        center.dy - outerRadius * math.cos(angle),
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

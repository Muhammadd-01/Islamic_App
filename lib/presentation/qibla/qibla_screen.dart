import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Makkah coordinates
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  double? _userLat;
  double? _userLng;
  double? _qiblaDirection;
  bool _isLoading = true;
  String _error = '';
  double _compassHeading = 0;

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initLocation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      // Request permission
      final permission = await Permission.location.request();
      if (permission.isDenied || permission.isPermanentlyDenied) {
        setState(() {
          _error = 'Location permission denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Please enable location services.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
        _qiblaDirection = _calculateQiblaDirection(_userLat!, _userLng!);
        _isLoading = false;
      });

      // Listen for heading changes (simulated - real implementation needs compass package)
      _startCompassSimulation();
    } catch (e) {
      setState(() {
        _error = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  void _startCompassSimulation() {
    // Simulate compass heading changes for demo
    // In production, use flutter_compass package for real heading
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          // Simulate slight compass movement
          _compassHeading += (math.Random().nextDouble() - 0.5) * 2;
          _compassHeading = _compassHeading % 360;
        });
      } else {
        timer.cancel();
      }
    });
  }

  double _calculateQiblaDirection(double userLat, double userLng) {
    // Convert to radians
    final lat1 = userLat * (math.pi / 180);
    final lng1 = userLng * (math.pi / 180);
    final lat2 = _kaabaLat * (math.pi / 180);
    final lng2 = _kaabaLng * (math.pi / 180);

    // Calculate direction using spherical trigonometry
    final dLng = lng2 - lng1;
    final y = math.sin(dLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    var direction = math.atan2(y, x) * (180 / math.pi);
    direction = (direction + 360) % 360;

    return direction;
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371; // km
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLng = (lng2 - lng1) * (math.pi / 180);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _initLocation();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? _buildErrorView()
          : _buildCompassView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassView() {
    final distance = _calculateDistance(
      _userLat!,
      _userLng!,
      _kaabaLat,
      _kaabaLng,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Direction Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  'Direction',
                  '${_qiblaDirection!.toStringAsFixed(1)}°',
                  Icons.explore,
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _buildInfoColumn(
                  'Distance',
                  '${distance.toStringAsFixed(0)} km',
                  Icons.straighten,
                ),
              ],
            ),
          ).animate().fade().slideY(begin: -0.1, end: 0),

          const SizedBox(height: 40),

          // Compass
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey.shade100, Colors.grey.shade200],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
              ),

              // Compass dial
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: CustomPaint(painter: _CompassDialPainter()),
              ),

              // Qibla needle
              Transform.rotate(
                    angle:
                        (_qiblaDirection! - _compassHeading) * (math.pi / 180),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mosque,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 2.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.02, 1.02),
                  ),

              // Center dot
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Instructions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Point your device in the direction of the mosque icon to face the Qibla. Keep device flat and away from magnets.',
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Location info
          Text(
            'Your Location: ${_userLat!.toStringAsFixed(4)}°, ${_userLng!.toStringAsFixed(4)}°',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final majorPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2;

    final minorPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw tick marks
    for (int i = 0; i < 360; i += 10) {
      final angle = i * (math.pi / 180) - (math.pi / 2);
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;

      final startRadius = isCardinal
          ? radius - 30
          : (isMajor ? radius - 20 : radius - 12);
      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );

      canvas.drawLine(start, end, isMajor ? majorPaint : minorPaint);
    }

    // Draw cardinal directions
    final directions = {'N': 0, 'E': 90, 'S': 180, 'W': 270};
    directions.forEach((text, degree) {
      final angle = degree * (math.pi / 180) - (math.pi / 2);
      final offset = Offset(
        center.dx + (radius - 50) * math.cos(angle) - 8,
        center.dy + (radius - 50) * math.sin(angle) - 10,
      );

      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: text == 'N' ? AppColors.primary : Colors.grey.shade700,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

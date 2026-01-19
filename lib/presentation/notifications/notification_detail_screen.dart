import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({super.key, required this.notification});

  IconData _getIcon() {
    final type = notification['type'] ?? 'general';
    switch (type) {
      case 'prayer':
        return Icons.access_time;
      case 'event':
        return Icons.event;
      case 'announcement':
        return Icons.campaign;
      case 'reminder':
        return Icons.notifications_active;
      case 'update':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor() {
    final type = notification['type'] ?? 'general';
    switch (type) {
      case 'prayer':
        return const Color(0xFF10B981);
      case 'event':
        return const Color(0xFFEC4899);
      case 'announcement':
        return const Color(0xFF3B82F6);
      case 'reminder':
        return const Color(0xFFF59E0B);
      case 'update':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.primaryGold;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Recently';
      }
      return DateFormat('EEEE, MMMM d, y • h:mm a').format(date);
    } catch (_) {
      return 'Recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = notification['title'] ?? 'Notification';
    final body = notification['body'] ?? notification['message'] ?? '';
    final timestamp = notification['timestamp'] ?? notification['createdAt'];
    final type = notification['type'] ?? 'general';
    final color = _getColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_getIcon(), size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type.toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade().scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
            ),

            const SizedBox(height: 24),

            // Timestamp
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(timestamp),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ).animate().fade(delay: 100.ms),

            const SizedBox(height: 24),

            // Divider
            Divider(color: Colors.grey.withValues(alpha: 0.3)),

            const SizedBox(height: 24),

            // Body Content
            const Text(
              'Message',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Text(
                body.isNotEmpty ? body : 'No additional details available.',
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Can add navigation to related content here
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Got It'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ).animate().fade(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

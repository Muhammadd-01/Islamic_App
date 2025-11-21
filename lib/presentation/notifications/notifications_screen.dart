import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationsNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    return [
      NotificationItem(
        id: '1',
        title: 'New Hadith of the Day',
        description: 'Read the new hadith from Sahih Bukhari.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: '2',
        title: 'Reminder for Maghrib Prayer',
        description: 'Maghrib prayer time is in 15 minutes.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationItem(
        id: '3',
        title: 'New Islamic Article Published',
        description: 'Check out "The Importance of Charity" in Articles.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void markAllAsRead() {
    state = [
      for (final n in state)
        NotificationItem(
          id: n.id,
          title: n.title,
          description: n.description,
          timestamp: n.timestamp,
          isRead: true,
        ),
    ];
  }

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id)
          NotificationItem(
            id: n.id,
            title: n.title,
            description: n.description,
            timestamp: n.timestamp,
            isRead: true,
          )
        else
          n,
    ];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<NotificationItem>>(() {
      return NotificationsNotifier();
    });

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  color: notification.isRead
                      ? null
                      : AppColors.primary.withValues(alpha: 0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.notifications,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.description),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Mark as read on tap
                      ref
                          .read(notificationsProvider.notifier)
                          .markAsRead(notification.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for notification settings
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((
      ref,
    ) {
      return NotificationSettingsNotifier();
    });

class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool prayerReminders;
  final bool dailyInspiration;
  final bool newContent;
  final bool promotions;

  NotificationSettings({
    this.pushNotificationsEnabled = true,
    this.prayerReminders = true,
    this.dailyInspiration = true,
    this.newContent = true,
    this.promotions = false,
  });

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? prayerReminders,
    bool? dailyInspiration,
    bool? newContent,
    bool? promotions,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      dailyInspiration: dailyInspiration ?? this.dailyInspiration,
      newContent: newContent ?? this.newContent,
      promotions: promotions ?? this.promotions,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettings(
      pushNotificationsEnabled: prefs.getBool('push_notifications') ?? true,
      prayerReminders: prefs.getBool('prayer_reminders') ?? true,
      dailyInspiration: prefs.getBool('daily_inspiration') ?? true,
      newContent: prefs.getBool('new_content') ?? true,
      promotions: prefs.getBool('promotions') ?? false,
    );
  }

  Future<void> setPushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', value);
    state = state.copyWith(pushNotificationsEnabled: value);
  }

  Future<void> setPrayerReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_reminders', value);
    state = state.copyWith(prayerReminders: value);
  }

  Future<void> setDailyInspiration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_inspiration', value);
    state = state.copyWith(dailyInspiration: value);
  }

  Future<void> setNewContent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('new_content', value);
    state = state.copyWith(newContent: value);
  }

  Future<void> setPromotions(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promotions', value);
    state = state.copyWith(promotions: value);
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Master Toggle
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: AppColors.primaryGold,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Push Notifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              settings.pushNotificationsEnabled
                                  ? 'Notifications are ON - You\'ll receive alerts even when app is closed'
                                  : 'Notifications are OFF - You\'ll only see them when you open the app',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    title: const Text('Enable Push Notifications'),
                    subtitle: Text(
                      settings.pushNotificationsEnabled
                          ? 'Receive notifications on your device'
                          : 'Only see notifications inside the app',
                    ),
                    value: settings.pushNotificationsEnabled,
                    activeColor: AppColors.primaryGold,
                    onChanged: (value) {
                      notifier.setPushNotifications(value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'NOTIFICATION TYPES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
          ),
          // Individual Notification Types
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildNotificationToggle(
                  icon: Icons.access_time,
                  title: 'Prayer Reminders',
                  subtitle: 'Get reminded for prayer times',
                  value: settings.prayerReminders,
                  onChanged: settings.pushNotificationsEnabled
                      ? (value) => notifier.setPrayerReminders(value)
                      : null,
                ),
                const Divider(height: 1),
                _buildNotificationToggle(
                  icon: Icons.lightbulb_outline,
                  title: 'Daily Inspiration',
                  subtitle: 'Daily quotes and reminders',
                  value: settings.dailyInspiration,
                  onChanged: settings.pushNotificationsEnabled
                      ? (value) => notifier.setDailyInspiration(value)
                      : null,
                ),
                const Divider(height: 1),
                _buildNotificationToggle(
                  icon: Icons.new_releases_outlined,
                  title: 'New Content',
                  subtitle: 'When new articles or videos are added',
                  value: settings.newContent,
                  onChanged: settings.pushNotificationsEnabled
                      ? (value) => notifier.setNewContent(value)
                      : null,
                ),
                const Divider(height: 1),
                _buildNotificationToggle(
                  icon: Icons.local_offer_outlined,
                  title: 'Promotions & Updates',
                  subtitle: 'Special offers and app updates',
                  value: settings.promotions,
                  onChanged: settings.pushNotificationsEnabled
                      ? (value) => notifier.setPromotions(value)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    settings.pushNotificationsEnabled
                        ? 'You will receive notifications on your device even when the app is closed.'
                        : 'Notifications will only appear when you open the app. You won\'t receive any alerts when the app is closed.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    final isEnabled = onChanged != null;
    return ListTile(
      leading: Icon(icon, color: isEnabled ? AppColors.primary : Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: isEnabled ? null : Colors.grey),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isEnabled ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppColors.primaryGold,
        onChanged: onChanged,
      ),
    );
  }
}

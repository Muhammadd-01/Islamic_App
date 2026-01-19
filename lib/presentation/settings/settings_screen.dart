import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';
import 'package:islamic_app/core/providers/language_provider.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Appearance'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Dark Mode'),
                  secondary: const Icon(
                    Icons.dark_mode,
                    color: AppColors.primary,
                  ),
                  value: isDarkMode,
                  onChanged: (value) {
                    ref
                        .read(themeProvider.notifier)
                        .setTheme(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Language'),
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  trailing: Consumer(
                    builder: (context, ref, child) {
                      final locale = ref.watch(languageProvider);
                      final String currentLanguage = locale.languageCode == 'ur'
                          ? 'Urdu'
                          : locale.languageCode == 'ar'
                          ? 'Arabic'
                          : 'English';

                      return DropdownButton<String>(
                        value: currentLanguage,
                        underline: const SizedBox(),
                        items: ['English', 'Urdu', 'Arabic'].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            final code = newValue == 'Urdu'
                                ? 'ur'
                                : newValue == 'Arabic'
                                ? 'ar'
                                : 'en';
                            ref
                                .read(languageProvider.notifier)
                                .setLanguage(code);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Audio'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text('Reciter Selection'),
              leading: const Icon(Icons.mic, color: AppColors.primary),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/reciters'),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Notifications'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text('Notification Settings'),
              leading: const Icon(
                Icons.notifications,
                color: AppColors.primary,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/notification-settings'),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Help & Support'),
                  leading: const Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Mock Help Center
                    AppSnackbar.showInfo(context, 'Opening Help Center...');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Privacy Policy'),
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.primary,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Mock Privacy Policy
                    AppSnackbar.showInfo(context, 'Opening Privacy Policy...');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('About App'),
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'DeenSphere',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGold.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/deensphere_logo.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ),
                      children: [
                        const Text(
                          'Serving Islam, Fostering Unity.\n\nA comprehensive Islamic application featuring Quran, Hadith, Prayer Times, and more.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text('Share App'),
              leading: const Icon(Icons.share, color: AppColors.primary),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Mock Share
                AppSnackbar.showInfo(context, 'Sharing app link...');
              },
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoggingOut
                  ? null
                  : () async {
                      setState(() => _isLoggingOut = true);
                      await ref.read(authRepositoryProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoggingOut ? Colors.grey : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoggingOut
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

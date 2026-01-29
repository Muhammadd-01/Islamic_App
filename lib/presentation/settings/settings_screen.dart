import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';
import 'package:islamic_app/core/providers/language_provider.dart';
import 'package:islamic_app/core/providers/region_provider.dart';
import 'package:islamic_app/core/providers/user_provider.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';
import 'package:islamic_app/core/localization/app_localizations.dart';

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

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(l10n.translate('appearance')),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text(l10n.translate('dark_mode')),
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
                  title: Text(l10n.translate('language')),
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  trailing: Consumer(
                    builder: (context, ref, child) {
                      final locale = ref.watch(languageProvider);
                      final String currentLanguage = _getLanguageName(
                        locale.languageCode,
                      );

                      return DropdownButton<String>(
                        value: currentLanguage,
                        underline: const SizedBox(),
                        items:
                            [
                              'English',
                              'العربية',
                              'اردو',
                              'Türkçe',
                              'Bahasa Indonesia',
                              'Français',
                              'Español',
                              'বাংলা',
                              'हिन्दी',
                              'Русский',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            final code = _getLanguageCode(newValue);
                            ref
                                .read(languageProvider.notifier)
                                .setLanguage(code);
                          }
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Consumer(
                  builder: (context, ref, child) {
                    final regionsAsync = ref.watch(regionsStreamProvider);
                    final selectedRegion = ref.watch(selectedRegionProvider);
                    final userProfile = ref.watch(userProfileProvider).value;
                    final lockStatus = ref.watch(regionLockProvider);

                    final String officialRegion =
                        userProfile?.region ?? 'Global';
                    final bool isDifferent = selectedRegion != officialRegion;
                    final bool isLocked = !lockStatus.canChange;

                    return Column(
                      children: [
                        ListTile(
                          title: const Text('Region'),
                          leading: const Icon(
                            Icons.public,
                            color: AppColors.primary,
                          ),
                          subtitle: isLocked
                              ? Text(
                                  'Region lock: ${lockStatus.remainingDays} days left',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                          trailing: regionsAsync.when(
                            data: (regions) {
                              final items = ['Global', ...regions];
                              final currentValue =
                                  items.contains(selectedRegion)
                                  ? selectedRegion
                                  : 'Global';

                              return DropdownButton<String>(
                                value: currentValue,
                                underline: const SizedBox(),
                                onChanged: isLocked
                                    ? null
                                    : (newValue) {
                                        if (newValue != null) {
                                          ref
                                              .read(
                                                selectedRegionProvider.notifier,
                                              )
                                              .setRegion(newValue);
                                        }
                                      },
                                items: items.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (_, __) => const Icon(Icons.error_outline),
                          ),
                        ),
                        if (isDifferent && !isLocked)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(userRepositoryProvider)
                                        .updateUserProfile(
                                          region: selectedRegion,
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Region updated successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Save Selection'),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
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
            child: Column(
              children: [
                ListTile(
                  title: const Text('Reciter Selection'),
                  leading: const Icon(Icons.mic, color: AppColors.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/reciters'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Adhan Selection'),
                  leading: const Icon(
                    Icons.notifications_active,
                    color: AppColors.primary,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/adhan-selection'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.translate('notifications')),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(l10n.translate('notifications')),
              leading: const Icon(
                Icons.notifications,
                color: AppColors.primary,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/notification-settings'),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.translate('support')),
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
              title: Text(l10n.translate('share_app')),
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
                  : Text(l10n.translate('logout')),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'ur':
        return 'اردو';
      case 'tr':
        return 'Türkçe';
      case 'id':
        return 'Bahasa Indonesia';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'bn':
        return 'বাংলা';
      case 'hi':
        return 'हिन्दी';
      case 'ru':
        return 'Русский';
      default:
        return 'English';
    }
  }

  String _getLanguageCode(String name) {
    switch (name) {
      case 'العربية':
        return 'ar';
      case 'اردو':
        return 'ur';
      case 'Türkçe':
        return 'tr';
      case 'Bahasa Indonesia':
        return 'id';
      case 'Français':
        return 'fr';
      case 'Español':
        return 'es';
      case 'বাংলা':
        return 'bn';
      case 'हिन्दी':
        return 'hi';
      case 'Русский':
        return 'ru';
      default:
        return 'en';
    }
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

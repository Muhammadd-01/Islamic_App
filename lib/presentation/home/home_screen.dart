import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/providers/user_provider.dart';
import 'package:islamic_app/presentation/prayer/prayer_provider.dart';
import 'package:islamic_app/presentation/prayer/prayer_tracker_provider.dart';
import 'package:islamic_app/presentation/hadith/hadith_provider.dart';
import 'package:islamic_app/data/repositories/questions_repository.dart';
import 'package:islamic_app/data/repositories/cart_repository.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/core/localization/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayerAsync = ref.watch(nextPrayerProvider);
    final dailyHadithAsync = ref.watch(dailyHadithProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Animated Background with Pattern
          _AnimatedBackground(isDark: isDark),

          // Content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Section with Date
                      _GreetingSection(ref: ref)
                          .animate()
                          .fade(duration: 500.ms)
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 28),

                      // Next Prayer Card (Hero)
                      _EnhancedPrayerCard(nextPrayerAsync: nextPrayerAsync)
                          .animate()
                          .fade(duration: 600.ms, delay: 100.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Quick Stats Row
                      _QuickStatsRow()
                          .animate()
                          .fade(duration: 500.ms, delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 28),

                      // Daily Inspiration (Hadith)
                      dailyHadithAsync.when(
                        data: (hadith) => hadith != null
                            ? _DailyInspirationCard(hadith: hadith)
                                  .animate()
                                  .fade(duration: 500.ms, delay: 300.ms)
                                  .slideY(begin: 0.1, end: 0)
                            : const SizedBox.shrink(),
                        loading: () => const _ShimmerCard(height: 140),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 28),

                      // Featured Tools Section
                      _SectionHeader(
                        title: l10n.translate('featured_tools'),
                        onSeeAll: () => context.push('/all-tools'),
                      ).animate().fade(delay: 400.ms),
                      const SizedBox(height: 16),
                      const _FeaturedToolsGrid()
                          .animate()
                          .fade(delay: 450.ms)
                          .slideX(begin: 0.1, end: 0),

                      const SizedBox(height: 28),

                      // Quick Actions Grid
                      _SectionHeader(
                        title: l10n.translate('explore'),
                      ).animate().fade(delay: 500.ms),
                      const SizedBox(height: 16),
                      _QuickActionsGrid().animate().fade(delay: 550.ms),

                      const SizedBox(height: 28),

                      // News Section
                      _SectionHeader(
                        title: l10n.translate('global_news'),
                        onSeeAll: () => context.push('/news'),
                      ).animate().fade(delay: 600.ms),
                      const SizedBox(height: 16),
                      _NewsPreviewCard().animate().fade(delay: 650.ms),

                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppColors.goldTileGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/deensphere_logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(width: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              children: [
                TextSpan(
                  text: 'Deen',
                  style: TextStyle(color: AppColors.primaryWhite),
                ),
                TextSpan(
                  text: 'Sphere',
                  style: TextStyle(color: AppColors.primaryGold),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Cart Icon with Badge
        IconButton(
          icon: Consumer(
            builder: (context, ref, child) {
              final cartCount = ref.watch(cartItemCountProvider);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).cardColor
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cartCount > 9 ? '9+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          onPressed: () => context.push('/cart'),
        ),
        // Notifications Icon with Badge
        IconButton(
          icon: Consumer(
            builder: (context, ref, child) {
              final unreadCountAsync = ref.watch(
                unreadNotificationsCountProvider,
              );
              final unreadCount = unreadCountAsync.maybeWhen(
                data: (count) => count,
                orElse: () => 0,
              );

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).cardColor
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          onPressed: () => context.push('/notifications'),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).cardColor
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.person_outline,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.primary,
            ),
          ),
          onPressed: () => context.push('/profile'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// Animated Background with Islamic Pattern
class _AnimatedBackground extends StatelessWidget {
  final bool isDark;

  const _AnimatedBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.backgroundDark, AppColors.surfaceDark]
                  : [
                      AppColors.backgroundLight,
                      AppColors.primary.withValues(alpha: 0.03),
                    ],
            ),
          ),
        ),

        // Animated circles
        Positioned(
          top: -80,
          right: -80,
          child:
              Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 5.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                  ),
        ),

        Positioned(
          bottom: 200,
          left: -100,
          child:
              Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.1),
                          AppColors.secondary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 6.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                  ),
        ),

        // Decorative Prophet Stamp background (centered, no square border)
        Center(
          child: Opacity(
            opacity: isDark ? 0.06 : 0.08,
            child: ClipOval(
              child: Image.asset(
                'assets/images/prophet_stamp.jpg',
                width: 280,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image not found
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mosque,
                        size: 150,
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ﷺ',
                        style: TextStyle(
                          fontSize: 60,
                          fontFamily: 'Amiri',
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Greeting Section with Date
class _GreetingSection extends StatelessWidget {
  final WidgetRef ref;

  const _GreetingSection({required this.ref});

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.translate('good_morning');
    if (hour < 17) return l10n.translate('good_afternoon');
    return l10n.translate('good_evening');
  }

  String _getIslamicGreeting() {
    return 'السلام عليكم';
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        final userName = user?.name ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getIslamicGreeting(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(width: 8),
                Text(
                  _getGreeting(context),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        );
      },
      loading: () => _buildDefaultGreeting(context),
      error: (_, __) => _buildDefaultGreeting(context),
    );
  }

  Widget _buildDefaultGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _getIslamicGreeting(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text('•', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(width: 8),
            Text(
              _getGreeting(context),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).translate('welcome'),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// Enhanced Prayer Card with Dynamic Colors
class _EnhancedPrayerCard extends ConsumerWidget {
  final AsyncValue<String> nextPrayerAsync;

  const _EnhancedPrayerCard({required this.nextPrayerAsync});

  // Get gradient colors based on prayer time
  List<Color> _getPrayerGradient(WidgetRef ref) {
    final prayerName = ref.watch(nextPrayerNameProvider);
    switch (prayerName) {
      case 'Fajr':
        // Dawn - deep purple to soft blue
        return const [
          Color(0xFF4C1D95), // Deep violet
          Color(0xFF6366F1), // Soft indigo
          Color(0xFF818CF8), // Light purple
        ];
      case 'Dhuhr':
        // Midday - warm amber to gold
        return const [
          Color(0xFFF59E0B), // Amber
          Color(0xFFFBBF24), // Yellow
          Color(0xFFD97706), // Deep amber
        ];
      case 'Asr':
        // Afternoon - soft orange to muted gold
        return const [
          Color(0xFFEA580C), // Orange
          Color(0xFFF97316), // Light orange
          Color(0xFFD97706), // Amber
        ];
      case 'Maghrib':
        // Sunset - deep orange to dark purple
        return const [
          Color(0xFFDC2626), // Red-orange
          Color(0xFFEA580C), // Deep orange
          Color(0xFF7C3AED), // Purple
        ];
      case 'Isha':
      default:
        // Night - deep navy to soft purple
        return const [
          Color(0xFF1E1B4B), // Deep navy
          Color(0xFF312E81), // Indigo
          Color(0xFF4C1D95), // Purple
        ];
    }
  }

  // Get icon based on prayer time
  IconData _getPrayerIcon(WidgetRef ref) {
    final prayerName = ref.watch(nextPrayerNameProvider);
    switch (prayerName) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradientColors = _getPrayerGradient(ref);
    final nextPrayer = ref.watch(nextPrayerNameProvider);
    final prayerIcon = _getPrayerIcon(ref);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time_filled,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).translate('next_prayer'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nextPrayer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getEstimatedTime(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            prayerIcon,
                            color: Colors.white,
                            size: 36,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          duration: 2.seconds,
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                        ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Time Remaining:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 10),
                      nextPrayerAsync.when(
                        data: (time) => Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        loading: () => const CupertinoActivityIndicator(
                          color: Colors.white,
                        ),
                        error: (_, __) => const Text(
                          '--:--:--',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEstimatedTime() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 6) return '5:15 AM';
    if (hour >= 6 && hour < 12) return '12:30 PM';
    if (hour >= 12 && hour < 15) return '3:45 PM';
    if (hour >= 15 && hour < 17) return '3:45 PM';
    if (hour >= 17 && hour < 19) return '6:15 PM';
    if (hour >= 19 && hour < 21) return '7:45 PM';
    return '5:15 AM';
  }
}

// Quick Stats Row - Now fetches dynamic prayer tracking data
class _QuickStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch prayer tracking for today
    final prayerTrackingAsync = ref.watch(todayPrayerTrackingProvider);

    final prayerStats = prayerTrackingAsync.when(
      data: (tracking) {
        final completed = tracking.completedCount;
        return '$completed/5';
      },
      loading: () => '...',
      error: (_, __) => '0/5',
    );

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            value: '7',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.menu_book,
            iconColor: AppColors.primary,
            value: 'Pg 45',
            label: 'Last Read',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            value: prayerStats,
            label: 'Prayers',
          ),
        ),
      ],
    ).animate().fade().slideX(begin: 0.2, end: 0, delay: 300.ms);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// Daily Inspiration Card - Animated Carousel
class _DailyInspirationCard extends StatefulWidget {
  final Hadith hadith;

  const _DailyInspirationCard({required this.hadith});

  @override
  State<_DailyInspirationCard> createState() => _DailyInspirationCardState();
}

class _DailyInspirationCardState extends State<_DailyInspirationCard> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isPaused = false;

  // Sample ayat and quotes - in production these would come from Firebase
  final List<Map<String, dynamic>> _inspirations = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initInspirations();
    _startAutoScroll();
  }

  void _initInspirations() {
    _inspirations.addAll([
      {
        'type': 'hadith',
        'title': 'Hadith of the Day',
        'icon': Icons.auto_stories,
        'text': widget.hadith.english,
        'source': widget.hadith.book,
        'color': const Color(0xFF3B82F6),
      },
      {
        'type': 'ayat',
        'title': 'Ayat of the Day',
        'icon': Icons.menu_book,
        'text': 'Indeed, with hardship comes ease.',
        'source': 'Surah Ash-Sharh (94:6)',
        'color': const Color(0xFF10B981),
      },
      {
        'type': 'quote',
        'title': 'Quote of the Day',
        'icon': Icons.format_quote,
        'text':
            'The ink of the scholar is more sacred than the blood of the martyr.',
        'source': 'Prophet Muhammad ﷺ',
        'color': const Color(0xFF8B5CF6),
      },
    ]);
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isPaused) {
        final nextIndex = (_currentIndex + 1) % _inspirations.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanDown: (_) => setState(() => _isPaused = true),
              onPanEnd: (_) => setState(() => _isPaused = false),
              onPanCancel: () => setState(() => _isPaused = false),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _inspirations.length,
                itemBuilder: (context, index) {
                  final item = _inspirations[index];
                  return _InspirationSlide(
                    title: item['title'],
                    text: item['text'],
                    source: item['source'],
                    icon: item['icon'],
                    color: item['color'],
                  );
                },
              ),
            ),
          ),
          // Page indicators
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _inspirations.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.primaryGold
                        : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.2, end: 0, delay: 400.ms);
  }
}

class _InspirationSlide extends StatelessWidget {
  final String title;
  final String text;
  final String source;
  final IconData icon;
  final Color color;

  const _InspirationSlide({
    required this.title,
    required this.text,
    required this.source,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              '"$text"',
              style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                source,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }
}

// Featured Tools Grid (No Scrolling)
class _FeaturedToolsGrid extends StatelessWidget {
  const _FeaturedToolsGrid();

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolData(
        'Tasbeeh',
        Icons.fingerprint,
        const Color(0xFF0D9488),
        '/tasbeeh',
      ),
      _ToolData('99 Names', Icons.stars, const Color(0xFF8B5CF6), '/names'),
      _ToolData(
        'History',
        Icons.history_edu,
        const Color(0xFF7C3AED),
        '/history',
      ),
      _ToolData('Courses', Icons.school, const Color(0xFFEC4899), '/courses'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tools.asMap().entries.map((entry) {
        final index = entry.key;
        final tool = entry.value;
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 40 - 24) / 3,
          child: _FeaturedToolCard(
            title: tool.title,
            icon: tool.icon,
            color: tool.color,
            onTap: () => context.push(tool.route),
          ).animate(delay: (50 * index).ms).fade().slideY(begin: 0.1, end: 0),
        );
      }).toList(),
    );
  }
}

class _ToolData {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _ToolData(this.title, this.icon, this.color, this.route);
}

class _FeaturedToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeaturedToolCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isDark ? 0.25 : 0.15),
              color.withValues(alpha: isDark ? 0.10 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.4 : 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.15),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Actions Grid - Premium Redesign
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('Quran', Icons.book, const Color(0xFF10B981), '/quran'),
      _ActionData(
        'Hadith',
        Icons.menu_book,
        const Color(0xFF3B82F6),
        '/hadith',
      ),
      _ActionData(
        'Dua',
        Icons.volunteer_activism,
        const Color(0xFFEC4899),
        '/duas',
      ),
      _ActionData(
        'Calendar',
        Icons.calendar_month,
        const Color(0xFF14B8A6),
        '/calendar',
      ),
      _ActionData(
        'Q&A',
        Icons.chat_bubble_outline,
        const Color(0xFF8B5CF6),
        '/qa',
      ),
      _ActionData(
        'Scholars',
        Icons.school,
        const Color(0xFF7C3AED),
        '/scholars',
      ),
      _ActionData(
        'Library',
        Icons.library_books,
        const Color(0xFFEA580C),
        '/library',
      ),
      _ActionData(
        'Religions',
        Icons.balance,
        const Color(0xFF6366F1),
        '/religions',
      ),
      _ActionData(
        'Debate',
        Icons.forum,
        const Color(0xFFEF4444),
        '/debate-panel',
      ),
      _ActionData(
        'Scientists',
        Icons.science,
        const Color(0xFF0EA5E9),
        '/muslim-scientists',
      ),
      _ActionData(
        'Politics',
        Icons.account_balance,
        const Color(0xFF9333EA),
        '/politics',
      ),
      _ActionData(
        'Settings',
        Icons.settings,
        const Color(0xFF6B7280),
        '/settings',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _PremiumActionCard(
              icon: action.icon,
              label: action.label,
              color: action.color,
              onTap: () => context.push(action.route),
            )
            .animate(delay: (30 * index).ms)
            .fade()
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
      },
    );
  }
}

class _ActionData {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  _ActionData(this.label, this.icon, this.color, this.route);
}

class _PremiumActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PremiumActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]
                : [Colors.white, color.withValues(alpha: 0.08)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : color.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer Loading Card
class _ShimmerCard extends StatelessWidget {
  final double height;

  const _ShimmerCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.1));
  }
}

// News Preview Card for Home Screen
class _NewsPreviewCard extends StatelessWidget {
  const _NewsPreviewCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/news'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF059669),
              const Color(0xFF059669).withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.newspaper, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stay Updated',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get the latest global news and updates',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

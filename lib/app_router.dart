import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/presentation/navigation/scaffold_with_nav_bar.dart';
import 'package:islamic_app/presentation/qa/qa_screen.dart';
import 'package:islamic_app/presentation/quran/quran_screen.dart';
import 'package:islamic_app/presentation/quran/surah_detail_screen.dart';
// import 'package:islamic_app/presentation/quran/surah_detail_screen.dart';
import 'package:islamic_app/presentation/prayer/prayer_screen.dart';
import 'package:islamic_app/presentation/home/home_screen.dart';
import 'package:islamic_app/presentation/tasbeeh/tasbeeh_screen.dart';
import 'package:islamic_app/presentation/names/names_of_allah_screen.dart';
import 'package:islamic_app/presentation/qibla/qibla_screen.dart';
import 'package:islamic_app/presentation/hadith/hadith_categories_screen.dart';
import 'package:islamic_app/presentation/hadith/hadith_list_screen.dart';
import 'package:islamic_app/presentation/hadith/hadith_detail_screen.dart';
import 'package:islamic_app/presentation/articles/articles_list_screen.dart';
import 'package:islamic_app/presentation/articles/article_detail_screen.dart';
import 'package:islamic_app/presentation/dua/dua_categories_screen.dart';
import 'package:islamic_app/presentation/dua/dua_list_screen.dart';
import 'package:islamic_app/presentation/dua/dua_detail_screen.dart';
import 'package:islamic_app/presentation/auth/login_screen.dart';
import 'package:islamic_app/presentation/profile/user_profile_screen.dart';
import 'package:islamic_app/presentation/bookmarks/bookmarks_screen.dart';
import 'package:islamic_app/presentation/calendar/calendar_screen.dart';
import 'package:islamic_app/presentation/auth/signup_screen.dart';
import 'package:islamic_app/presentation/auth/forgot_password_screen.dart';
import 'package:islamic_app/presentation/settings/settings_screen.dart';
import 'package:islamic_app/presentation/notifications/notifications_screen.dart';
import 'package:islamic_app/presentation/quran_audio/reciter_selection_screen.dart';
import 'package:islamic_app/presentation/settings/adhan_selection_screen.dart';
import 'package:islamic_app/presentation/quran_audio/surah_audio_screen.dart';
import 'package:islamic_app/presentation/splash/splash_screen.dart';
import 'package:islamic_app/presentation/onboarding/onboarding_screen.dart';
import 'package:islamic_app/domain/entities/surah.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/domain/entities/article.dart';
import 'package:islamic_app/domain/entities/dua.dart';
import 'package:islamic_app/domain/entities/scholar.dart';
import 'package:islamic_app/domain/entities/book.dart';
import 'package:islamic_app/presentation/scholars/scholars_list_screen.dart';
import 'package:islamic_app/presentation/scholars/scholar_detail_screen.dart';
import 'package:islamic_app/presentation/library/library_screen.dart';
import 'package:islamic_app/presentation/library/book_detail_screen.dart';
import 'package:islamic_app/presentation/courses/courses_screen.dart';
import 'package:islamic_app/presentation/library/book_reader_screen.dart';
import 'package:islamic_app/presentation/education/study_religions_screen.dart';
import 'package:islamic_app/presentation/education/debate_panel_screen.dart';
import 'package:islamic_app/presentation/profile/edit_profile_screen.dart';
import 'package:islamic_app/presentation/cart/cart_screen.dart';
import 'package:islamic_app/presentation/checkout/checkout_screen.dart';
import 'package:islamic_app/presentation/muslim_scientists/muslim_scientists_screen.dart';
import 'package:islamic_app/presentation/orders/my_orders_screen.dart';

import 'package:islamic_app/presentation/auth/auth_gate.dart';
import 'package:islamic_app/presentation/tools/all_tools_screen.dart';
import 'package:islamic_app/presentation/politics/politics_screen.dart';
import 'package:islamic_app/presentation/prayer/prayer_tracker_history_screen.dart';
import 'package:islamic_app/presentation/news/news_screen.dart';
import 'package:islamic_app/presentation/history/history_screen.dart';
import 'package:islamic_app/presentation/beliefs/beliefs_screen.dart';
import 'package:islamic_app/presentation/religions/religions_hub_screen.dart';
import 'package:islamic_app/presentation/settings/notification_settings_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    // Auth Gate - Outside ShellRoute (no navbar)
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AuthGate()),
    ),
    // Main Shell with Navbar (authenticated routes)
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/qa',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: QAScreen()),
        ),
        GoRoute(
          path: '/quran',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: QuranScreen()),
          routes: [
            GoRoute(
              path: ':number',
              builder: (context, state) {
                final number = int.parse(state.pathParameters['number']!);
                final surah = state.extra as Surah?;
                return SurahDetailScreen(surahNumber: number, surah: surah);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/prayer',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PrayerScreen()),
        ),
        GoRoute(
          path: '/tasbeeh',
          builder: (context, state) => const TasbeehScreen(),
        ),
        GoRoute(
          path: '/names',
          builder: (context, state) => const NamesOfAllahScreen(),
        ),
        GoRoute(
          path: '/qibla',
          builder: (context, state) => const QiblaScreen(),
        ),
        GoRoute(
          path: '/hadith',
          builder: (context, state) => const HadithCategoriesScreen(),
          routes: [
            GoRoute(
              path: ':bookId',
              builder: (context, state) {
                final bookId = state.pathParameters['bookId']!;
                final bookName = state.extra as String? ?? bookId;
                return HadithListScreen(bookId: bookId, bookName: bookName);
              },
              routes: [
                GoRoute(
                  path: ':hadithId',
                  builder: (context, state) {
                    final hadith = state.extra as Hadith?;
                    if (hadith == null) {
                      // If no hadith data, redirect to hadith categories
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.go('/hadith');
                      });
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return HadithDetailScreen(hadith: hadith);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/articles',
          builder: (context, state) => const ArticlesListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final article = state.extra as Article;
                return ArticleDetailScreen(article: article);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/duas',
          builder: (context, state) => const DuaCategoriesScreen(),
          routes: [
            GoRoute(
              path: ':categoryId',
              builder: (context, state) {
                final categoryId = state.pathParameters['categoryId']!;
                final categoryName = state.extra as String;
                return DuaListScreen(
                  categoryId: categoryId,
                  categoryName: categoryName,
                );
              },
              routes: [
                GoRoute(
                  path: ':duaId',
                  builder: (context, state) {
                    final dua = state.extra as Dua;
                    return DuaDetailScreen(dua: dua);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const UserProfileScreen(),
        ),
        GoRoute(
          path: '/bookmarks',
          builder: (context, state) => const BookmarksScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/all-tools',
          builder: (context, state) => const AllToolsScreen(),
        ),
        GoRoute(
          path: '/politics',
          builder: (context, state) => const PoliticsScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/beliefs',
          builder: (context, state) => const BeliefsScreen(),
        ),
        GoRoute(
          path: '/religions-hub',
          builder: (context, state) => const ReligionsHubScreen(),
        ),
        GoRoute(
          path: '/religions',
          builder: (context, state) => const StudyReligionsScreen(),
        ),
        GoRoute(
          path: '/reciters',
          builder: (context, state) => const ReciterSelectionScreen(),
        ),
        GoRoute(
          path: '/adhan-selection',
          builder: (context, state) => const AdhanSelectionScreen(),
        ),
      ],
    ),
    GoRoute(path: '/', redirect: (_, __) => '/home'),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/scholars',
      builder: (context, state) => const ScholarsListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final scholar = state.extra as Scholar;
            return ScholarDetailScreen(scholar: scholar);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final book = state.extra as Book;
            return BookDetailScreen(book: book);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/surah-audio/:surahId',
      builder: (context, state) {
        final surahId = state.pathParameters['surahId']!;
        final surahName = state.extra as String;
        return SurahAudioScreen(surahId: surahId, surahName: surahName);
      },
    ),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/courses',
      builder: (context, state) => const CoursesScreen(),
    ),
    GoRoute(
      path: '/book-reader',
      builder: (context, state) {
        final book = state.extra as Book;
        return BookReaderScreen(book: book);
      },
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/debate-panel',
      builder: (context, state) => const DebatePanelScreen(),
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/my-orders',
      builder: (context, state) => const MyOrdersScreen(),
    ),
    GoRoute(
      path: '/muslim-scientists',
      builder: (context, state) => const MuslimScientistsScreen(),
    ),
    GoRoute(
      path: '/prayer-history',
      builder: (context, state) => const PrayerTrackerHistoryScreen(),
    ),
    GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
  ],
);

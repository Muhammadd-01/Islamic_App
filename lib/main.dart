import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/app_router.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:islamic_app/core/providers/language_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:islamic_app/firebase_options.dart';
import 'package:islamic_app/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islamic_app/data/services/supabase_service.dart';
import 'package:islamic_app/data/services/notification_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint("Initialization: Widgets Binding Initialized");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Initialization: Firebase App Initialized");

  await SupabaseService.initialize(
    url: 'https://lphfrnpvgudrcxbmwloq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwaGZybnB2Z3VkcmN4Ym13bG9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2MzI0NTYsImV4cCI6MjA4NDIwODQ1Nn0.BFX2XO0zAjz4wMuFHlSxT1Tim9LUEhu1K_mkLcce46g',
  );
  debugPrint("Initialization: Supabase Service Initialized");

  await NotificationService.initialize();
  debugPrint("Initialization: Notification Service Initialized");

  debugPrint("Initialization: Running App...");
  runApp(const ProviderScope(child: IslamicApp()));
}

class IslamicApp extends ConsumerWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'DeenSphere',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ur'),
        Locale('tr'),
        Locale('id'),
        Locale('fr'),
        Locale('es'),
        Locale('bn'),
        Locale('hi'),
        Locale('ru'),
      ],
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (child == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return child;
      },
    );
  }
}

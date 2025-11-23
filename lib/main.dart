import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/app_router.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:islamic_app/core/providers/language_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:islamic_app/firebase_options.dart';
import 'package:islamic_app/data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Commented out until Firebase is configured
 await SupabaseService.initialize(
    url: 'https://xauintsqmapuenkzwxmz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhdWludHNxbWFwdWVua3p3eG16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4ODQ5MzQsImV4cCI6MjA3OTQ2MDkzNH0.Q89Rz-RFhe2WLD5ywYlZ-_OD1xm7O5bP4kKqToft3L4',
  );
  runApp(const ProviderScope(child: IslamicApp()));
}

class IslamicApp extends ConsumerWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Islamic App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/presentation/quran_audio/mini_player.dart';
import 'package:islamic_app/core/localization/app_localizations.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (int index) => _onItemTapped(index, context),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: AppLocalizations.of(context).translate('home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline),
                selectedIcon: const Icon(Icons.chat_bubble),
                label: AppLocalizations.of(context).translate('qa'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.book_outlined),
                selectedIcon: const Icon(Icons.book),
                label: AppLocalizations.of(context).translate('quran'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.access_time_outlined),
                selectedIcon: const Icon(Icons.access_time_filled),
                label: AppLocalizations.of(context).translate('prayer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/qa')) return 1;
    if (location.startsWith('/quran')) return 2;
    if (location.startsWith('/prayer')) return 3;
    if (location.startsWith('/home') || location == '/') return 0;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/qa');
        break;
      case 2:
        context.go('/quran');
        break;
      case 3:
        context.go('/prayer');
        break;
    }
  }
}

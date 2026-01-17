import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// All Tools Screen - Shows all Featured Tools and Explore items
class AllToolsScreen extends StatelessWidget {
  const AllToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Combined list of all tools
    final allTools = [
      // Featured Tools
      _ToolItem(
        'Tasbeeh',
        Icons.fingerprint,
        const Color(0xFF0D9488),
        '/tasbeeh',
      ),
      _ToolItem('Qibla', Icons.explore, const Color(0xFFF97316), '/qibla'),
      _ToolItem('99 Names', Icons.stars, const Color(0xFF8B5CF6), '/names'),
      _ToolItem(
        'Audio',
        Icons.headphones,
        const Color(0xFF3B82F6),
        '/reciters',
      ),
      _ToolItem('Courses', Icons.school, const Color(0xFFEC4899), '/courses'),
      // Explore Items
      _ToolItem('Quran', Icons.book, const Color(0xFF10B981), '/quran'),
      _ToolItem('Hadith', Icons.menu_book, const Color(0xFF3B82F6), '/hadith'),
      _ToolItem(
        'Dua',
        Icons.volunteer_activism,
        const Color(0xFFEC4899),
        '/duas',
      ),
      _ToolItem(
        'Calendar',
        Icons.calendar_month,
        const Color(0xFF14B8A6),
        '/calendar',
      ),
      _ToolItem(
        'Q&A',
        Icons.chat_bubble_outline,
        const Color(0xFF8B5CF6),
        '/qa',
      ),
      _ToolItem('Scholars', Icons.school, const Color(0xFF7C3AED), '/scholars'),
      _ToolItem(
        'Library',
        Icons.library_books,
        const Color(0xFFEA580C),
        '/library',
      ),
      _ToolItem(
        'Religions',
        Icons.balance,
        const Color(0xFF6366F1),
        '/study-religions',
      ),
      _ToolItem(
        'Debate',
        Icons.forum,
        const Color(0xFFEF4444),
        '/debate-panel',
      ),
      _ToolItem(
        'Scientists',
        Icons.science,
        const Color(0xFF0EA5E9),
        '/muslim-scientists',
      ),
      _ToolItem(
        'Politics',
        Icons.account_balance,
        const Color(0xFF9333EA),
        '/politics',
      ),
      _ToolItem(
        'Settings',
        Icons.settings,
        const Color(0xFF6B7280),
        '/settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('All Tools'), centerTitle: true),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.9,
        ),
        itemCount: allTools.length,
        itemBuilder: (context, index) {
          final tool = allTools[index];
          return _ToolCard(
                icon: tool.icon,
                label: tool.label,
                color: tool.color,
                onTap: () => context.push(tool.route),
                isDark: isDark,
              )
              .animate(delay: (30 * index).ms)
              .fade()
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
        },
      ),
    );
  }
}

class _ToolItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  _ToolItem(this.label, this.icon, this.color, this.route);
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 26),
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

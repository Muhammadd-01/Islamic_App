import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/quran/quran_provider.dart';

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Quran'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: surahsAsync.when(
        data: (surahs) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  surah.englishName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${surah.revelationType} • ${surah.numberOfAyahs} Verses',
                ),
                trailing: Text(
                  surah.name,
                  style: const TextStyle(
                    fontFamily:
                        'Amiri', // Assuming we add Arabic font later, or use system default
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                onTap: () {
                  context.push('/quran/${surah.number}', extra: surah);
                },
              ),
            ).animate().fade().slideX(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: index * 50),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

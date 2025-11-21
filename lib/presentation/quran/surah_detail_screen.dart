import 'package:flutter/material.dart';
import 'package:islamic_app/domain/entities/surah.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class SurahDetailScreen extends StatelessWidget {
  final int surahNumber;
  final Surah? surah; // Passed via extra

  const SurahDetailScreen({required this.surahNumber, this.surah, super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, we would fetch verses here using surahNumber if surah is null or just to get verses
    // For now, we'll mock some verses

    return Scaffold(
      appBar: AppBar(
        title: Text(surah?.englishName ?? 'Surah $surahNumber'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Column(
              children: [
                Text(
                  surah?.name ?? '',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${surah?.revelationType} • ${surah?.numberOfAyahs} Verses',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                const Text(
                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: surah?.numberOfAyahs ?? 10, // Mock count if null
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Mock Arabic Verse
                      Text(
                        'Verse ${index + 1} Arabic Text Placeholder',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mock Translation
                      Text(
                        'This is the translation of verse ${index + 1}. It explains the meaning of the Arabic text above.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

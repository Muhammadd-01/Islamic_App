import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/hadith/hadith_provider.dart';

class HadithListScreen extends ConsumerWidget {
  final String bookId;
  final String bookName;

  const HadithListScreen({
    super.key,
    required this.bookId,
    required this.bookName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadithsAsync = ref.watch(hadithListProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: Text(bookName), centerTitle: true),
      body: hadithsAsync.when(
        data: (hadiths) {
          if (hadiths.isEmpty) {
            return const Center(
              child: Text('No hadiths found for this book yet.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hadiths.length,
            itemBuilder: (context, index) {
              final hadith = hadiths[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    context.push('/hadith/$bookId/${hadith.id}', extra: hadith);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Hadith ${hadith.id}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (hadith.chapter != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hadith.chapter!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hadith.arabic,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            height: 1.8,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hadith.english,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade().slideY(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: index * 50),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/data/repositories/scholars_repository_impl.dart';

class ScholarsListScreen extends ConsumerWidget {
  const ScholarsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scholarsAsync = ref.watch(scholarsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Scholar'), centerTitle: true),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.2),
                  AppColors.primaryGold.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.video_call,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book Live Sessions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get personalized guidance with video consultations',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fade().slideY(begin: -0.1, end: 0),
          // Scholars list
          Expanded(
            child: scholarsAsync.when(
              data: (scholars) {
                if (scholars.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No scholars available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: scholars.length,
                  itemBuilder: (context, index) {
                    final scholar = scholars[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => context.go(
                          '/scholars/${scholar.id}',
                          extra: scholar,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'scholar_${scholar.id}',
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primaryGold.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      scholar.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.primaryGold.withValues(
                                          alpha: 0.2,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: AppColors.primaryGold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scholar.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      scholar.specialty,
                                      style: TextStyle(
                                        color: AppColors.primaryGold,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        if (scholar.isAvailableFor1on1) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'Available',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '\$${scholar.consultationFee.toInt()}/hr',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ] else
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Currently Unavailable',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade().slideX(
                      begin: 0.08,
                      end: 0,
                      delay: Duration(milliseconds: index * 80),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

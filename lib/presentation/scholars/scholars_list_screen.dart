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

    return Scaffold(
      appBar: AppBar(title: const Text('Ask a Scholar'), centerTitle: true),
      body: scholarsAsync.when(
        data: (scholars) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scholars.length,
          itemBuilder: (context, index) {
            final scholar = scholars[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    context.go('/scholars/${scholar.id}', extra: scholar),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'scholar_${scholar.id}',
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(scholar.imageUrl),
                          onBackgroundImageError: (_, __) =>
                              const Icon(Icons.person),
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
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (scholar.isAvailableFor1on1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Available for 1-on-1',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fade().slideX(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: index * 100),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

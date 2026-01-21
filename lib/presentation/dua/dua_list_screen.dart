import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/presentation/dua/dua_provider.dart';

class DuaListScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const DuaListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync = ref.watch(duaListProvider(categoryName));

    return Scaffold(
      appBar: AppBar(title: Text(categoryName), centerTitle: true),
      body: duasAsync.when(
        data: (duas) {
          if (duas.isEmpty) {
            return const Center(
              child: Text('No duas found for this category yet.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: duas.length,
            itemBuilder: (context, index) {
              final dua = duas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    context.push('/duas/$categoryId/${dua.id}', extra: dua);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dua.arabic,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20,
                            height: 1.8,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dua.translation,
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

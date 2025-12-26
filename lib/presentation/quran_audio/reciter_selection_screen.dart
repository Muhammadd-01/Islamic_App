import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/quran_audio/quran_audio_provider.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

class ReciterSelectionScreen extends ConsumerWidget {
  const ReciterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recitersAsync = ref.watch(recitersProvider);
    final selectedReciterAsync = ref.watch(selectedReciterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Reciter'), centerTitle: true),
      body: recitersAsync.when(
        data: (reciters) {
          return selectedReciterAsync.when(
            data: (selectedId) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reciters.length,
                itemBuilder: (context, index) {
                  final reciter = reciters[index];
                  final isSelected = reciter.id == (selectedId ?? 'alafasy');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        reciter.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(reciter.language),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () async {
                        await ref
                            .read(quranAudioRepositoryProvider)
                            .setSelectedReciter(reciter.id);
                        ref.invalidate(selectedReciterProvider);
                        if (context.mounted) {
                          AppSnackbar.showSuccess(
                            context,
                            '${reciter.name} selected',
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

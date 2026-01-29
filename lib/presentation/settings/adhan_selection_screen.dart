import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/quran_audio/quran_audio_provider.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

class AdhanSelectionScreen extends ConsumerWidget {
  const AdhanSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhansAsync = ref.watch(adhansProvider);
    final selectedAdhanId = ref.watch(selectedAdhanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Adhan'), centerTitle: true),
      body: adhansAsync.when(
        data: (adhans) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adhans.length,
            itemBuilder: (context, index) {
              final adhan = adhans[index];
              final isSelected = adhan.id == selectedAdhanId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: isSelected
                      ? const BorderSide(color: AppColors.primary, width: 2)
                      : BorderSide.none,
                ),
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
                      Icons.notifications_active,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  title: Text(
                    adhan.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: adhan.description != null
                      ? Text(adhan.description!)
                      : null,
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(selectedAdhanProvider.notifier).setAdhan(adhan.id);
                    AppSnackbar.showSuccess(
                      context,
                      '${adhan.name} Adhan selected',
                    );
                  },
                ),
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

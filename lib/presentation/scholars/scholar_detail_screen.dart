import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/domain/entities/scholar.dart';

class ScholarDetailScreen extends ConsumerWidget {
  final Scholar scholar;

  const ScholarDetailScreen({super.key, required this.scholar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(scholar.name),
              background: Hero(
                tag: 'scholar_${scholar.id}',
                child: Image.network(
                  scholar.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 100),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          scholar.specialty,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (scholar.isAvailableFor1on1)
                        Row(
                          children: [
                            const Icon(Icons.videocam, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '\$${scholar.consultationFee.toInt()}/hr',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Biography',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    scholar.bio,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (scholar.isAvailableFor1on1)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showBookingDialog(context),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Book 1-on-1 Session'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ).animate().fade().scale(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a time for your session:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _TimeSlot(time: '10:00 AM'),
                _TimeSlot(time: '02:00 PM'),
                _TimeSlot(time: '04:30 PM'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking request sent successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _TimeSlot extends StatefulWidget {
  final String time;
  const _TimeSlot({required this.time});

  @override
  State<_TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<_TimeSlot> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(widget.time),
      selected: _selected,
      onSelected: (value) => setState(() => _selected = value),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: _selected ? AppColors.primary : null,
        fontWeight: _selected ? FontWeight.bold : null,
      ),
    );
  }
}

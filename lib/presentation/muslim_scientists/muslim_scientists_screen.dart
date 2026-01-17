import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/muslim_scientists/muslim_scientists_provider.dart';
import 'package:islamic_app/domain/entities/invention.dart';
import 'package:islamic_app/domain/entities/scientist.dart';

class MuslimScientistsScreen extends ConsumerStatefulWidget {
  const MuslimScientistsScreen({super.key});

  @override
  ConsumerState<MuslimScientistsScreen> createState() =>
      _MuslimScientistsScreenState();
}

class _MuslimScientistsScreenState extends ConsumerState<MuslimScientistsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Heritage'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Inventions'),
            Tab(text: 'Scientists'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [InventionsList(), ScientistsList()],
      ),
    );
  }
}

class InventionsList extends ConsumerWidget {
  const InventionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventionsAsync = ref.watch(inventionsProvider);

    return inventionsAsync.when(
      data: (inventions) {
        if (inventions.isEmpty) {
          return const Center(child: Text('No inventions found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inventions.length,
          itemBuilder: (context, index) {
            final invention = inventions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                title: Text(
                  invention.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text('Discovered by ${invention.discoveredBy}'),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  if (invention.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        invention.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 100,
                              child: Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    invention.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  _DetailRow('Discovered By', invention.discoveredBy),
                  _DetailRow('Year', invention.year),
                  if (invention.refinedBy != null)
                    _DetailRow('Refined By', invention.refinedBy!),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Details:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  ...invention.details.map(
                    (d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text(d)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(
              begin: 0.1,
              end: 0,
              delay: (100 * index).ms,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class ScientistsList extends ConsumerWidget {
  const ScientistsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scientistsAsync = ref.watch(scientistsProvider);

    return scientistsAsync.when(
      data: (scientists) {
        if (scientists.isEmpty) {
          return const Center(child: Text('No scientists found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scientists.length,
          itemBuilder: (context, index) {
            final scientist = scientists[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundImage: scientist.imageUrl.isNotEmpty
                      ? NetworkImage(scientist.imageUrl)
                      : null,
                  child: scientist.imageUrl.isEmpty
                      ? Text(scientist.name[0])
                      : null,
                ),
                title: Text(
                  scientist.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(scientist.field),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  Text(scientist.bio, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Divider(),
                  _DetailRow('Life', scientist.birthDeath),
                  _DetailRow('Field', scientist.field),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Achievements:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  ...scientist.achievements.map(
                    (d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text(d)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(
              begin: 0.1,
              end: 0,
              delay: (100 * index).ms,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

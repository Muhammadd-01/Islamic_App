import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/muslim_scientists/muslim_scientists_provider.dart';
import 'package:islamic_app/domain/entities/invention.dart';
import 'package:islamic_app/domain/entities/scientist.dart';
import 'package:url_launcher/url_launcher.dart';

class MuslimScientistsScreen extends ConsumerStatefulWidget {
  const MuslimScientistsScreen({super.key});

  static const String youtubeChannelUrl = 'https://www.youtube.com/@DeenSphere';

  @override
  ConsumerState<MuslimScientistsScreen> createState() =>
      _MuslimScientistsScreenState();
}

class _MuslimScientistsScreenState extends ConsumerState<MuslimScientistsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _contentType = 'videos'; // 'videos' or 'documents'
  String _category = 'muslim'; // 'muslim' or 'western'

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

  Future<void> _launchYouTube() async {
    final Uri url = Uri.parse(MuslimScientistsScreen.youtubeChannelUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
      }
    }
  }

  void _showComparisonDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const InventionComparisonSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientists & Inventions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: _showComparisonDialog,
            tooltip: 'Compare Inventions',
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: _launchYouTube,
            tooltip: 'YouTube Channel',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          tabs: const [
            Tab(text: 'Inventions'),
            Tab(text: 'Scientists'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category Toggle (Muslim/Western)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _CategoryButton(
                    icon: Icons.mosque,
                    label: 'Muslim',
                    isSelected: _category == 'muslim',
                    onTap: () => setState(() => _category = 'muslim'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoryButton(
                    icon: Icons.public,
                    label: 'Western',
                    isSelected: _category == 'western',
                    onTap: () => setState(() => _category = 'western'),
                  ),
                ),
              ],
            ),
          ),
          // Content Type Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ContentTypeButton(
                    icon: Icons.video_library,
                    label: 'Videos',
                    isSelected: _contentType == 'videos',
                    onTap: () => setState(() => _contentType = 'videos'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContentTypeButton(
                    icon: Icons.description,
                    label: 'Documents',
                    isSelected: _contentType == 'documents',
                    onTap: () => setState(() => _contentType = 'documents'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                InventionsList(category: _category, contentType: _contentType),
                ScientistsList(category: _category, contentType: _contentType),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launchYouTube,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('YouTube', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class InventionsList extends ConsumerWidget {
  final String category;
  final String contentType;

  const InventionsList({
    super.key,
    required this.category,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventionsAsync = ref.watch(inventionsProvider);

    return inventionsAsync.when(
      data: (inventions) {
        // Filter by category and contentType from Firebase data
        final filtered = inventions.where((i) {
          final categoryMatch =
              i.category.toLowerCase() == category.toLowerCase();
          final contentMatch =
              (contentType == 'videos' && i.contentType == 'video') ||
              (contentType == 'documents' && i.contentType == 'document');
          return categoryMatch && contentMatch;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${category == "muslim" ? "Muslim" : "Western"} ${contentType == "videos" ? "video" : "document"} inventions found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add content via admin panel',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final invention = filtered[index];
            return _InventionCard(
              invention: invention,
              index: index,
              contentType: contentType,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _InventionCard extends StatelessWidget {
  final Invention invention;
  final int index;
  final String contentType;

  const _InventionCard({
    required this.invention,
    required this.index,
    required this.contentType,
  });

  void _downloadDocument(BuildContext context) async {
    // Placeholder document URL
    final url = Uri.parse(
      'https://example.com/docs/${invention.title.toLowerCase().replaceAll(' ', '_')}.pdf',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }

  void _shareDocument(BuildContext context) {
    final content =
        '''
${invention.title}

Discovered by: ${invention.discoveredBy}
Year: ${invention.year}

${invention.description}

Shared from DeenSphere App
''';
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                contentType == 'videos' ? Icons.play_circle : Icons.description,
                color: AppColors.primaryGold,
              ),
            ),
            title: Text(
              invention.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('${invention.discoveredBy} • ${invention.year}'),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              if (invention.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    invention.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(invention.description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              if (contentType == 'documents')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadDocument(context),
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGold,
                          side: const BorderSide(color: AppColors.primaryGold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareDocument(context),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGold,
                          side: const BorderSide(color: AppColors.primaryGold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0, delay: (80 * index).ms);
  }
}

class ScientistsList extends ConsumerWidget {
  final String category;
  final String contentType;

  const ScientistsList({
    super.key,
    required this.category,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scientistsAsync = ref.watch(scientistsProvider);

    return scientistsAsync.when(
      data: (scientists) {
        // Filter by category and contentType from Firebase data
        final filtered = scientists.where((s) {
          final categoryMatch =
              s.category.toLowerCase() == category.toLowerCase();
          final contentMatch =
              (contentType == 'videos' && s.contentType == 'video') ||
              (contentType == 'documents' && s.contentType == 'document');
          return categoryMatch && contentMatch;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${category == "muslim" ? "Muslim" : "Western"} ${contentType == "videos" ? "video" : "document"} scientists found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add content via admin panel',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final scientist = filtered[index];
            return _ScientistCard(
              scientist: scientist,
              index: index,
              contentType: contentType,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _ScientistCard extends StatelessWidget {
  final Scientist scientist;
  final int index;
  final String contentType;

  const _ScientistCard({
    required this.scientist,
    required this.index,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
          backgroundImage: scientist.imageUrl.isNotEmpty
              ? NetworkImage(scientist.imageUrl)
              : null,
          child: scientist.imageUrl.isEmpty
              ? Text(
                  scientist.name[0],
                  style: const TextStyle(color: AppColors.primaryGold),
                )
              : null,
        ),
        title: Text(
          scientist.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('${scientist.field} • ${scientist.birthDeath}'),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(scientist.bio, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Achievements:',
            style: TextStyle(fontWeight: FontWeight.bold),
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
    ).animate().fade().slideY(begin: 0.1, end: 0, delay: (80 * index).ms);
  }
}

// Invention Comparison Feature
class InventionComparisonSheet extends ConsumerStatefulWidget {
  const InventionComparisonSheet({super.key});

  @override
  ConsumerState<InventionComparisonSheet> createState() =>
      _InventionComparisonSheetState();
}

class _InventionComparisonSheetState
    extends ConsumerState<InventionComparisonSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final inventionsAsync = ref.watch(inventionsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: AppColors.primaryGold),
              const SizedBox(width: 12),
              const Text(
                'Compare Inventions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Search for an invention to see who discovered it first and its history',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search invention (e.g., Coffee, Algebra, Camera)...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryGold,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: inventionsAsync.when(
              data: (inventions) {
                final filtered = _searchQuery.isEmpty
                    ? inventions
                    : inventions
                          .where(
                            (i) =>
                                i.title.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                i.description.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Type to search inventions'
                              : 'No inventions found for "$_searchQuery"',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final invention = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb,
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        invention.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        invention.year,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _ComparisonRow(
                              'First Discovered By',
                              invention.discoveredBy,
                              isHighlighted: true,
                            ),
                            _ComparisonRow('Year', invention.year),
                            if (invention.refinedBy != null)
                              _ComparisonRow(
                                'Later Refined By',
                                invention.refinedBy!,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              invention.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _ComparisonRow(this.label, this.value, {this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? AppColors.primaryGold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContentTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primaryGold : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primaryGold : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

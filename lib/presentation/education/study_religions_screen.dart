import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Religion/Belief model
class ReligionBelief {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String type; // 'religion' or 'belief'
  final String contentType; // 'video' or 'document'
  final String videoUrl;
  final String documentUrl;

  ReligionBelief({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.contentType,
    required this.videoUrl,
    required this.documentUrl,
  });

  factory ReligionBelief.fromMap(Map<String, dynamic> map, String id) {
    return ReligionBelief(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? 'religion',
      contentType: map['contentType'] ?? 'video',
      videoUrl: map['videoUrl'] ?? '',
      documentUrl: map['documentUrl'] ?? '',
    );
  }
}

/// Provider for fetching religions & beliefs from Firebase
final religionsBeliefsProvider = FutureProvider<List<ReligionBelief>>((
  ref,
) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('religions')
        .get();
    if (snapshot.docs.isEmpty) {
      return _getDefaultItems();
    }
    return snapshot.docs
        .map((doc) => ReligionBelief.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    print('Error fetching religions: $e');
    return _getDefaultItems();
  }
});

List<ReligionBelief> _getDefaultItems() {
  return [
    ReligionBelief(
      id: 'default_1',
      name: 'Christianity',
      description: 'Based on the life and teachings of Jesus of Nazareth.',
      imageUrl: '',
      type: 'religion',
      contentType: 'video',
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: '',
    ),
    ReligionBelief(
      id: 'default_2',
      name: 'Judaism',
      description: 'The monotheistic religion of the Jewish people.',
      imageUrl: '',
      type: 'religion',
      contentType: 'video',
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: '',
    ),
    ReligionBelief(
      id: 'default_3',
      name: 'Atheism',
      description: 'The absence of belief in the existence of deities.',
      imageUrl: '',
      type: 'belief',
      contentType: 'video',
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: '',
    ),
  ];
}

/// Study Religions & Beliefs Screen
class StudyReligionsScreen extends ConsumerStatefulWidget {
  const StudyReligionsScreen({super.key});

  static const String youtubeChannelUrl = 'https://www.youtube.com/@DeenSphere';

  @override
  ConsumerState<StudyReligionsScreen> createState() =>
      _StudyReligionsScreenState();
}

class _StudyReligionsScreenState extends ConsumerState<StudyReligionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _contentType = 'videos';

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
    final Uri url = Uri.parse(StudyReligionsScreen.youtubeChannelUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
      }
    }
  }

  Future<void> _openContent(ReligionBelief item) async {
    final url = _contentType == 'videos' ? item.videoUrl : item.documentUrl;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No ${_contentType} available for ${item.name}'),
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open content')));
      }
    }
  }

  void _shareItem(ReligionBelief item) {
    final content =
        '''
${item.type == 'religion' ? 'Religion' : 'Belief'}: ${item.name}

${item.description}

Video: ${item.videoUrl}
Document: ${item.documentUrl}

Learn more from an Islamic perspective.

Shared from DeenSphere App
''';
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard!'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemsAsync = ref.watch(religionsBeliefsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Religions & Beliefs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: _launchYouTube,
            tooltip: 'Open YouTube Channel',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          tabs: const [
            Tab(text: 'Religions'),
            Tab(text: 'Beliefs'),
          ],
        ),
      ),
      body: itemsAsync.when(
        data: (items) {
          // Filter by type (religion/belief) AND by contentType (video/document)
          final selectedType = _contentType == 'videos' ? 'video' : 'document';
          final religions = items
              .where(
                (i) => i.type == 'religion' && i.contentType == selectedType,
              )
              .toList();
          final beliefs = items
              .where((i) => i.type == 'belief' && i.contentType == selectedType)
              .toList();

          return Column(
            children: [
              // Content Type Toggle
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ContentTypeButton(
                        label: 'Videos',
                        icon: Icons.play_circle_outline,
                        isSelected: _contentType == 'videos',
                        onTap: () => setState(() => _contentType = 'videos'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ContentTypeButton(
                        label: 'Documents',
                        icon: Icons.description_outlined,
                        isSelected: _contentType == 'documents',
                        onTap: () => setState(() => _contentType = 'documents'),
                      ),
                    ),
                  ],
                ),
              ),
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildItemsList(religions, isDark),
                    _buildItemsList(beliefs, isDark),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launchYouTube,
        backgroundColor: AppColors.primaryGold,
        icon: const Icon(Icons.play_arrow, color: Colors.black),
        label: const Text(
          'Watch Videos',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildItemsList(List<ReligionBelief> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later or use admin panel to add content',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ReligionCard(
          item: item,
          index: index,
          isDark: isDark,
          onTap: () => _openContent(item),
          onShare: () => _shareItem(item),
        );
      },
    );
  }
}

class _ContentTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContentTypeButton({
    required this.label,
    required this.icon,
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
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.2)
              : Theme.of(context).cardColor,
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
              color: isSelected ? AppColors.primaryGold : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryGold : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReligionCard extends StatelessWidget {
  final ReligionBelief item;
  final int index;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _ReligionCard({
    required this.item,
    required this.index,
    required this.isDark,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Image or Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: item.type == 'religion'
                          ? Colors.blue.withValues(alpha: 0.15)
                          : Colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                item.type == 'religion'
                                    ? Icons.public
                                    : Icons.psychology,
                                size: 30,
                                color: item.type == 'religion'
                                    ? Colors.blue
                                    : Colors.purple,
                              ),
                            ),
                          )
                        : Icon(
                            item.type == 'religion'
                                ? Icons.public
                                : Icons.psychology,
                            size: 30,
                            color: item.type == 'religion'
                                ? Colors.blue
                                : Colors.purple,
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: item.type == 'religion'
                                    ? Colors.blue.withValues(alpha: 0.15)
                                    : Colors.purple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.type == 'religion' ? 'Religion' : 'Belief',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.type == 'religion'
                                      ? Colors.blue
                                      : Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    onPressed: onShare,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fade(delay: Duration(milliseconds: 50 * index))
        .slideX(begin: 0.1, end: 0, delay: Duration(milliseconds: 50 * index));
  }
}

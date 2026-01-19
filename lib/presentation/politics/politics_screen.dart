import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/data/repositories/politics_repository.dart';
import 'package:islamic_app/domain/entities/politics_topic.dart';
import 'package:url_launcher/url_launcher.dart';

/// Politics Screen - Islamic and Western Political Content with Documents & Videos
class PoliticsScreen extends ConsumerStatefulWidget {
  const PoliticsScreen({super.key});

  static const String youtubeChannelUrl = 'https://www.youtube.com/@DeenSphere';

  @override
  ConsumerState<PoliticsScreen> createState() => _PoliticsScreenState();
}

class _PoliticsScreenState extends ConsumerState<PoliticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _contentType = 'videos'; // 'videos' or 'documents'

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
    final Uri url = Uri.parse(PoliticsScreen.youtubeChannelUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
      }
    }
  }

  List<PoliticsTopic> _filterTopics(
    List<PoliticsTopic> topics,
    String category,
  ) {
    return topics.where((t) {
      if (category == 'Islamic') {
        return t.category.toLowerCase() == 'islamic' ||
            t.category.toLowerCase() == 'muslim';
      } else {
        return t.category.toLowerCase() == 'western';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final politicsAsync = ref.watch(politicsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Politics'),
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
            Tab(text: 'Islamic Politics'),
            Tab(text: 'Western Politics'),
          ],
        ),
      ),
      body: politicsAsync.when(
        data: (topics) {
          final islamicTopics = _filterTopics(topics, 'Islamic');
          final westernTopics = _filterTopics(topics, 'Western');

          return Column(
            children: [
              // Content Type Toggle
              Container(
                padding: const EdgeInsets.all(16),
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
              // Content View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildContentList(islamicTopics, isDark),
                    _buildContentList(westernTopics, isDark),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launchYouTube,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('YouTube', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildContentList(List<PoliticsTopic> topics, bool isDark) {
    // Filter by content type availability
    final filteredTopics = topics.where((t) {
      if (_contentType == 'videos') return t.videoUrl.isNotEmpty;
      return t.documentUrl.isNotEmpty;
    }).toList();

    if (filteredTopics.isEmpty) {
      return const Center(child: Text("No content available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTopics.length,
      itemBuilder: (context, index) {
        final topic = filteredTopics[index];
        // Determine icon and color based on title keywords or default
        // Since we don't store icon/color in DB, we'll assign defaults here
        IconData icon = Icons.article;
        Color color = AppColors.primaryGold;

        if (topic.title.toLowerCase().contains('democracy')) {
          icon = Icons.how_to_vote;
          color = const Color(0xFF3B82F6);
        } else if (topic.title.toLowerCase().contains('money') ||
            topic.title.toLowerCase().contains('economics')) {
          icon = Icons.monetization_on;
          color = const Color(0xFFF59E0B);
        } else if (topic.title.toLowerCase().contains('caliphate')) {
          icon = Icons.account_balance;
          color = const Color(0xFF10B981);
        } else if (topic.title.toLowerCase().contains('law') ||
            topic.title.toLowerCase().contains('shariah')) {
          icon = Icons.gavel;
          color = const Color(0xFF14B8A6);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _contentType == 'videos'
                        ? Icons.play_circle
                        : Icons.description,
                    color: color,
                    size: 24,
                  ),
                ),
                title: Text(
                  topic.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    topic.description,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
                onTap: () {
                  if (_contentType == 'videos') {
                    _launchYouTube();
                  } else {
                    _showDocumentOptions(topic);
                  }
                },
              ),
              // Action buttons for documents
              if (_contentType == 'documents')
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadDocument(topic),
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Download PDF'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareDocument(topic),
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ).animate(delay: (50 * index).ms).fade().slideX(begin: 0.1, end: 0);
      },
    );
  }

  void _showDocumentOptions(PoliticsTopic topic) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              topic.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download PDF'),
              onTap: () {
                Navigator.pop(context);
                _downloadDocument(topic);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Document'),
              onTap: () {
                Navigator.pop(context);
                _shareDocument(topic);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadDocument(PoliticsTopic topic) async {
    final Uri url = Uri.parse(topic.documentUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }

  void _shareDocument(PoliticsTopic topic) {
    final content =
        '${topic.title}\n\n${topic.description}\n\nDocument: ${topic.documentUrl}\n\nShared from DeenSphere App';
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document info copied to clipboard!'),
        backgroundColor: AppColors.primaryGold,
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

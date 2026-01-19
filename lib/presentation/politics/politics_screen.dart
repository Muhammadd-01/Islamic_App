import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: Column(
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
                _buildContentList(_getIslamicTopics(), isDark),
                _buildContentList(_getWesternTopics(), isDark),
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

  List<_PoliticsTopic> _getIslamicTopics() => [
    _PoliticsTopic(
      'Caliphate System',
      'Understanding Islamic governance',
      Icons.account_balance,
      const Color(0xFF10B981),
      'https://example.com/caliphate.pdf',
    ),
    _PoliticsTopic(
      'Shura (Consultation)',
      'Collective decision-making',
      Icons.groups,
      const Color(0xFF3B82F6),
      'https://example.com/shura.pdf',
    ),
    _PoliticsTopic(
      'Islamic Economics',
      'Fair trade, zakat principles',
      Icons.monetization_on,
      const Color(0xFFF59E0B),
      'https://example.com/economics.pdf',
    ),
    _PoliticsTopic(
      'Social Justice',
      'Rights and equality in Islam',
      Icons.balance,
      const Color(0xFF8B5CF6),
      'https://example.com/justice.pdf',
    ),
    _PoliticsTopic(
      'Modern Muslim Nations',
      'Contemporary political systems',
      Icons.public,
      const Color(0xFFEC4899),
      'https://example.com/nations.pdf',
    ),
    _PoliticsTopic(
      'Islamic Law',
      'Shariah in governance',
      Icons.gavel,
      const Color(0xFF14B8A6),
      'https://example.com/law.pdf',
    ),
  ];

  List<_PoliticsTopic> _getWesternTopics() => [
    _PoliticsTopic(
      'Democracy & Islam',
      'Comparing democratic principles',
      Icons.how_to_vote,
      const Color(0xFF3B82F6),
      'https://example.com/democracy.pdf',
    ),
    _PoliticsTopic(
      'Secularism Analysis',
      'Islamic perspective on secularism',
      Icons.location_city,
      const Color(0xFF6366F1),
      'https://example.com/secularism.pdf',
    ),
    _PoliticsTopic(
      'Human Rights',
      'Western vs Islamic rights',
      Icons.people,
      const Color(0xFF10B981),
      'https://example.com/rights.pdf',
    ),
    _PoliticsTopic(
      'Global Politics',
      'Muslim world relations',
      Icons.public,
      const Color(0xFFEA580C),
      'https://example.com/global.pdf',
    ),
    _PoliticsTopic(
      'Political Philosophy',
      'Comparing political thought',
      Icons.psychology,
      const Color(0xFF8B5CF6),
      'https://example.com/philosophy.pdf',
    ),
    _PoliticsTopic(
      'Current Affairs',
      'Contemporary analysis',
      Icons.newspaper,
      const Color(0xFFEF4444),
      'https://example.com/affairs.pdf',
    ),
  ];

  Widget _buildContentList(List<_PoliticsTopic> topics, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: topic.color.withValues(alpha: 0.2)),
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
                        topic.color.withValues(alpha: 0.2),
                        topic.color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _contentType == 'videos'
                        ? Icons.play_circle
                        : Icons.description,
                    color: topic.color,
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
                            foregroundColor: topic.color,
                            side: BorderSide(color: topic.color),
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
                            foregroundColor: topic.color,
                            side: BorderSide(color: topic.color),
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

  void _showDocumentOptions(_PoliticsTopic topic) {
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

  Future<void> _downloadDocument(_PoliticsTopic topic) async {
    final Uri url = Uri.parse(topic.documentUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }

  void _shareDocument(_PoliticsTopic topic) {
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

class _PoliticsTopic {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String documentUrl;

  _PoliticsTopic(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.documentUrl,
  );
}

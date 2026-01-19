import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Study Religions Screen - Like Politics with Two Tabs and Videos/Documents
class StudyReligionsScreen extends StatefulWidget {
  const StudyReligionsScreen({super.key});

  static const String youtubeChannelUrl = 'https://www.youtube.com/@DeenSphere';

  @override
  State<StudyReligionsScreen> createState() => _StudyReligionsScreenState();
}

class _StudyReligionsScreenState extends State<StudyReligionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _contentType = 'videos'; // 'videos' or 'documents'

  // Main religions data
  final List<_Religion> _majorReligions = const [
    _Religion(
      name: 'Christianity',
      description: 'Based on the life and teachings of Jesus of Nazareth.',
      icon: '✝️',
      color: Color(0xFF3B82F6),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/christianity.pdf',
    ),
    _Religion(
      name: 'Judaism',
      description: 'The monotheistic religion of the Jewish people.',
      icon: '✡️',
      color: Color(0xFF8B5CF6),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/judaism.pdf',
    ),
    _Religion(
      name: 'Hinduism',
      description: 'An Indian religion or dharma, a way of life.',
      icon: '🕉️',
      color: Color(0xFFEC4899),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/hinduism.pdf',
    ),
    _Religion(
      name: 'Buddhism',
      description: 'A path of practice and spiritual development.',
      icon: '☸️',
      color: Color(0xFF10B981),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/buddhism.pdf',
    ),
    _Religion(
      name: 'Sikhism',
      description: 'A monotheistic religion founded in Punjab.',
      icon: '☬',
      color: Color(0xFFF59E0B),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/sikhism.pdf',
    ),
  ];

  // Other religions
  final List<_Religion> _otherReligions = const [
    _Religion(
      name: 'Zoroastrianism',
      description: 'Ancient Persian religion founded by Zoroaster.',
      icon: '🔥',
      color: Color(0xFFDC2626),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/zoroastrianism.pdf',
    ),
    _Religion(
      name: 'Jainism',
      description: 'An ancient Indian religion emphasizing non-violence.',
      icon: '🙏',
      color: Color(0xFF059669),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/jainism.pdf',
    ),
    _Religion(
      name: 'Shinto',
      description: 'The traditional religion of Japan.',
      icon: '⛩️',
      color: Color(0xFF7C3AED),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/shinto.pdf',
    ),
    _Religion(
      name: 'Confucianism',
      description: 'A system of philosophical and ethical teachings.',
      icon: '📜',
      color: Color(0xFF2563EB),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/confucianism.pdf',
    ),
    _Religion(
      name: 'Taoism',
      description: 'A philosophical and religious tradition from China.',
      icon: '☯️',
      color: Color(0xFF0891B2),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/taoism.pdf',
    ),
  ];

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

  Future<void> _openContent(_Religion religion) async {
    final url = _contentType == 'videos'
        ? religion.videoUrl
        : religion.documentUrl;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open content')));
      }
    }
  }

  void _shareReligion(_Religion religion) {
    final content =
        '''
Comparative Religion: ${religion.name}

${religion.description}

Video: ${religion.videoUrl}
Document: ${religion.documentUrl}

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Religions'),
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
            Tab(text: 'Major Religions'),
            Tab(text: 'Other Religions'),
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
                _buildReligionsList(_majorReligions),
                _buildReligionsList(_otherReligions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReligionsList(List<_Religion> religions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: religions.length,
      itemBuilder: (context, index) {
        final religion = religions[index];
        return _ReligionCard(
              religion: religion,
              contentType: _contentType,
              onTap: () => _openContent(religion),
              onShare: () => _shareReligion(religion),
            )
            .animate()
            .fade(delay: Duration(milliseconds: 50 * index))
            .slideY(begin: 0.05);
      },
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
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

class _ReligionCard extends StatelessWidget {
  final _Religion religion;
  final String contentType;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _ReligionCard({
    required this.religion,
    required this.contentType,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: religion.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    religion.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      religion.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      religion.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: religion.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        contentType == 'videos'
                            ? '📹 Watch Video'
                            : '📄 Read Document',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: religion.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.share, color: Colors.grey[400]),
                onPressed: onShare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Religion {
  final String name;
  final String description;
  final String icon;
  final Color color;
  final String videoUrl;
  final String documentUrl;

  const _Religion({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.videoUrl,
    required this.documentUrl,
  });
}

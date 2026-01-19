import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class StudyReligionsScreen extends StatefulWidget {
  const StudyReligionsScreen({super.key});

  static const String youtubeChannelUrl = 'https://www.youtube.com/@DeenSphere';

  @override
  State<StudyReligionsScreen> createState() => _StudyReligionsScreenState();
}

class _StudyReligionsScreenState extends State<StudyReligionsScreen> {
  String _contentType = 'videos'; // 'videos' or 'documents'

  final List<_Religion> _religions = const [
    _Religion(
      name: 'Christianity',
      description: 'Based on the life and teachings of Jesus of Nazareth.',
      icon: '✝️',
      color: Color(0xFF3B82F6),
      documentUrl: 'https://example.com/christianity.pdf',
    ),
    _Religion(
      name: 'Judaism',
      description: 'The monotheistic religion of the Jewish people.',
      icon: '✡️',
      color: Color(0xFF8B5CF6),
      documentUrl: 'https://example.com/judaism.pdf',
    ),
    _Religion(
      name: 'Hinduism',
      description: 'An Indian religion or dharma, a way of life.',
      icon: '🕉️',
      color: Color(0xFFEC4899),
      documentUrl: 'https://example.com/hinduism.pdf',
    ),
    _Religion(
      name: 'Buddhism',
      description: 'A path of practice and spiritual development.',
      icon: '☸️',
      color: Color(0xFF10B981),
      documentUrl: 'https://example.com/buddhism.pdf',
    ),
    _Religion(
      name: 'Sikhism',
      description: 'A monotheistic religion founded in Punjab.',
      icon: '☬',
      color: Color(0xFFF59E0B),
      documentUrl: 'https://example.com/sikhism.pdf',
    ),
    _Religion(
      name: 'Worldviews & Beliefs',
      description: 'Atheism, Agnosticism, Deism, Humanism and more.',
      icon: '🌐',
      color: Color(0xFF6B7280),
      documentUrl: '/beliefs', // Route to beliefs section
      isRoute: true,
    ),
  ];

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

  void _downloadDocument(_Religion religion) async {
    final Uri url = Uri.parse(religion.documentUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }

  void _shareDocument(_Religion religion) {
    final content =
        '''
Comparative Religion: ${religion.name}

${religion.description}

Document: ${religion.documentUrl}

Learn more about comparative religion from an Islamic perspective.

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparative Religion'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: _launchYouTube,
            tooltip: 'YouTube Channel',
          ),
        ],
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
          // Info Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Learn about other religions from an Islamic perspective for knowledge and dawah purposes.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Religions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _religions.length,
              itemBuilder: (context, index) {
                final religion = _religions[index];
                return _ReligionCard(
                  religion: religion,
                  index: index,
                  contentType: _contentType,
                  onVideo: _launchYouTube,
                  onDownload: () => _downloadDocument(religion),
                  onShare: () => _shareDocument(religion),
                );
              },
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

class _ReligionCard extends StatelessWidget {
  final _Religion religion;
  final int index;
  final String contentType;
  final VoidCallback onVideo;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const _ReligionCard({
    required this.religion,
    required this.index,
    required this.contentType,
    required this.onVideo,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: religion.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(religion.icon, style: const TextStyle(fontSize: 24)),
            ),
            title: Text(
              religion.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                religion.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: religion.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                contentType == 'videos' ? Icons.play_circle : Icons.description,
                color: religion.color,
                size: 20,
              ),
            ),
            onTap: contentType == 'videos' ? onVideo : onDownload,
          ),
          // Action buttons for documents
          if (contentType == 'documents')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: religion.color,
                        side: BorderSide(color: religion.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: religion.color,
                        side: BorderSide(color: religion.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fade().slideX(delay: (50 * index).ms, begin: 0.1, end: 0);
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

class _Religion {
  final String name;
  final String description;
  final String icon;
  final Color color;
  final String documentUrl;
  final bool isRoute;

  const _Religion({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.documentUrl,
    this.isRoute = false,
  });
}

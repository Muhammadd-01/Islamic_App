import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

/// Beliefs Screen - Like Politics with Two Tabs and Videos/Documents
class BeliefsScreen extends ConsumerStatefulWidget {
  const BeliefsScreen({super.key});

  static const String youtubeChannelUrl = 'https://www.youtube.com/@DeenSphere';

  @override
  ConsumerState<BeliefsScreen> createState() => _BeliefsScreenState();
}

class _BeliefsScreenState extends ConsumerState<BeliefsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _contentType = 'videos'; // 'videos' or 'documents'

  // Secular worldviews
  final List<_Belief> _secularBeliefs = const [
    _Belief(
      name: 'Atheism',
      description: 'The absence of belief in the existence of deities.',
      icon: Icons.close,
      color: Color(0xFFDC2626),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/atheism.pdf',
    ),
    _Belief(
      name: 'Agnosticism',
      description: 'The view that existence of God is unknown or unknowable.',
      icon: Icons.help_outline,
      color: Color(0xFFF59E0B),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/agnosticism.pdf',
    ),
    _Belief(
      name: 'Secular Humanism',
      description: 'Philosophy emphasizing human values without religion.',
      icon: Icons.people,
      color: Color(0xFF10B981),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/humanism.pdf',
    ),
    _Belief(
      name: 'Nihilism',
      description: 'The rejection of all religious and moral principles.',
      icon: Icons.blur_on,
      color: Color(0xFF6B7280),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/nihilism.pdf',
    ),
  ];

  // Philosophical worldviews
  final List<_Belief> _philosophicalBeliefs = const [
    _Belief(
      name: 'Deism',
      description:
          'Belief in a creator who does not intervene in the universe.',
      icon: Icons.brightness_5,
      color: Color(0xFF3B82F6),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/deism.pdf',
    ),
    _Belief(
      name: 'Pantheism',
      description: 'The belief that God is identical to the universe.',
      icon: Icons.public,
      color: Color(0xFF8B5CF6),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/pantheism.pdf',
    ),
    _Belief(
      name: 'Existentialism',
      description: 'Philosophy focusing on individual existence and freedom.',
      icon: Icons.person,
      color: Color(0xFFEC4899),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/existentialism.pdf',
    ),
    _Belief(
      name: 'Naturalism',
      description: 'The belief that only natural laws operate in the world.',
      icon: Icons.nature,
      color: Color(0xFF059669),
      videoUrl: 'https://www.youtube.com/@DeenSphere',
      documentUrl: 'https://example.com/naturalism.pdf',
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
    final Uri url = Uri.parse(BeliefsScreen.youtubeChannelUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
      }
    }
  }

  Future<void> _openContent(_Belief belief) async {
    final url = _contentType == 'videos' ? belief.videoUrl : belief.documentUrl;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open content')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beliefs & Worldviews'),
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
            Tab(text: 'Secular Views'),
            Tab(text: 'Philosophical'),
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
                _buildBeliefsList(_secularBeliefs),
                _buildBeliefsList(_philosophicalBeliefs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeliefsList(List<_Belief> beliefs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: beliefs.length,
      itemBuilder: (context, index) {
        final belief = beliefs[index];
        return _BeliefCard(
              belief: belief,
              contentType: _contentType,
              onTap: () => _openContent(belief),
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

class _BeliefCard extends StatelessWidget {
  final _Belief belief;
  final String contentType;
  final VoidCallback onTap;

  const _BeliefCard({
    required this.belief,
    required this.contentType,
    required this.onTap,
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
                  color: belief.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(belief.icon, size: 28, color: belief.color),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      belief.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      belief.description,
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
                        color: belief.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        contentType == 'videos'
                            ? '📹 Watch Video'
                            : '📄 Read Document',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: belief.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Belief {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String videoUrl;
  final String documentUrl;

  const _Belief({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.videoUrl,
    required this.documentUrl,
  });
}

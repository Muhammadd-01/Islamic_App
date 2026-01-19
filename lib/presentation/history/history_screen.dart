import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Islamic';
  String _selectedContentType = 'Videos';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final _youtubeChannelUrl = 'https://www.youtube.com/@DeenSphere';

  // Mock data - will be fetched from Firebase
  final List<_HistoryTopic> _islamicTopics = [
    _HistoryTopic(
      title: 'Prophet Muhammad ﷺ',
      description: 'The life and teachings of the final Prophet',
      videoUrl: 'https://www.youtube.com/watch?v=example1',
      documentUrl: 'https://example.com/prophet-life.pdf',
      era: 'Early Islam (570-632 CE)',
      imageUrl:
          'https://images.unsplash.com/photo-1564769625905-50e93615e769?w=400',
    ),
    _HistoryTopic(
      title: 'The Rashidun Caliphate',
      description: 'The era of the four rightly guided caliphs',
      videoUrl: 'https://www.youtube.com/watch?v=example2',
      documentUrl: 'https://example.com/rashidun.pdf',
      era: '632-661 CE',
      imageUrl:
          'https://images.unsplash.com/photo-1585036156171-384164a8c942?w=400',
    ),
    _HistoryTopic(
      title: 'Golden Age of Islam',
      description: 'Scientific and cultural achievements',
      videoUrl: 'https://www.youtube.com/watch?v=example3',
      documentUrl: 'https://example.com/golden-age.pdf',
      era: '8th-14th Century',
      imageUrl:
          'https://images.unsplash.com/photo-1564769625391-2f4c2b4d65fc?w=400',
    ),
    _HistoryTopic(
      title: 'Islamic Spain (Al-Andalus)',
      description: 'Islamic civilization in the Iberian Peninsula',
      videoUrl: 'https://www.youtube.com/watch?v=example4',
      documentUrl: 'https://example.com/andalus.pdf',
      era: '711-1492 CE',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    ),
    _HistoryTopic(
      title: 'Ottoman Empire',
      description: 'Rise and fall of the Ottoman dynasty',
      videoUrl: 'https://www.youtube.com/watch?v=example5',
      documentUrl: 'https://example.com/ottoman.pdf',
      era: '1299-1922 CE',
      imageUrl:
          'https://images.unsplash.com/photo-1527838832700-5059252407fa?w=400',
    ),
    _HistoryTopic(
      title: 'Mughal Empire',
      description: 'Islamic rule in Indian subcontinent',
      videoUrl: 'https://www.youtube.com/watch?v=example6',
      documentUrl: 'https://example.com/mughal.pdf',
      era: '1526-1857 CE',
      imageUrl:
          'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=400',
    ),
  ];

  final List<_HistoryTopic> _westernTopics = [
    _HistoryTopic(
      title: 'Ancient Greece',
      description: 'Birthplace of democracy and philosophy',
      videoUrl: 'https://www.youtube.com/watch?v=western1',
      documentUrl: 'https://example.com/greece.pdf',
      era: '800-31 BCE',
      imageUrl:
          'https://images.unsplash.com/photo-1555993539-1732b0258235?w=400',
    ),
    _HistoryTopic(
      title: 'Roman Empire',
      description: 'From Republic to Empire',
      videoUrl: 'https://www.youtube.com/watch?v=western2',
      documentUrl: 'https://example.com/rome.pdf',
      era: '27 BCE - 476 CE',
      imageUrl:
          'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
    ),
    _HistoryTopic(
      title: 'Medieval Europe',
      description: 'The Dark Ages and feudal system',
      videoUrl: 'https://www.youtube.com/watch?v=western3',
      documentUrl: 'https://example.com/medieval.pdf',
      era: '5th-15th Century',
      imageUrl:
          'https://images.unsplash.com/photo-1533154683220-1c1dc8672d42?w=400',
    ),
    _HistoryTopic(
      title: 'Renaissance',
      description: 'Rebirth of arts and science in Europe',
      videoUrl: 'https://www.youtube.com/watch?v=western4',
      documentUrl: 'https://example.com/renaissance.pdf',
      era: '14th-17th Century',
      imageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
    ),
    _HistoryTopic(
      title: 'Industrial Revolution',
      description: 'Transformation of manufacturing',
      videoUrl: 'https://www.youtube.com/watch?v=western5',
      documentUrl: 'https://example.com/industrial.pdf',
      era: '1760-1840',
      imageUrl:
          'https://images.unsplash.com/photo-1565793298595-6a879b1d9492?w=400',
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
    _searchController.dispose();
    super.dispose();
  }

  List<_HistoryTopic> get _filteredTopics {
    final topics = _selectedCategory == 'Islamic'
        ? _islamicTopics
        : _westernTopics;
    if (_searchQuery.isEmpty) return topics;
    return topics
        .where(
          (t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              t.era.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Future<void> _openYouTube() async {
    final uri = Uri.parse(_youtubeChannelUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: _openYouTube,
            tooltip: 'Watch on YouTube',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBrowseView(isDark), _buildTimelineView(isDark)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openYouTube,
        backgroundColor: AppColors.primaryGold,
        icon: const Icon(Icons.play_arrow, color: Colors.black),
        label: const Text(
          'Watch Videos',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildBrowseView(bool isDark) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search history...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            ),
          ),
        ).animate().fade().slideY(begin: -0.1, end: 0),

        // Category toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _CategoryButton(
                label: 'Islamic History',
                isSelected: _selectedCategory == 'Islamic',
                onTap: () => setState(() => _selectedCategory = 'Islamic'),
                icon: Icons.mosque,
              ),
              const SizedBox(width: 12),
              _CategoryButton(
                label: 'World History',
                isSelected: _selectedCategory == 'Western',
                onTap: () => setState(() => _selectedCategory = 'Western'),
                icon: Icons.public,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Content type toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _ContentTypeButton(
                label: 'Videos',
                isSelected: _selectedContentType == 'Videos',
                onTap: () => setState(() => _selectedContentType = 'Videos'),
                icon: Icons.play_circle,
              ),
              const SizedBox(width: 8),
              _ContentTypeButton(
                label: 'Documents',
                isSelected: _selectedContentType == 'Documents',
                onTap: () => setState(() => _selectedContentType = 'Documents'),
                icon: Icons.article,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Topics list
        Expanded(
          child: _filteredTopics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No results for "$_searchQuery"',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredTopics.length,
                  itemBuilder: (context, index) {
                    final topic = _filteredTopics[index];
                    return _TopicCard(
                      topic: topic,
                      contentType: _selectedContentType,
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTimelineView(bool isDark) {
    final topics = _selectedCategory == 'Islamic'
        ? _islamicTopics
        : _westernTopics;

    return Column(
      children: [
        // Category toggle in timeline
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _CategoryButton(
                label: 'Islamic',
                isSelected: _selectedCategory == 'Islamic',
                onTap: () => setState(() => _selectedCategory = 'Islamic'),
                icon: Icons.mosque,
              ),
              const SizedBox(width: 12),
              _CategoryButton(
                label: 'World',
                isSelected: _selectedCategory == 'Western',
                onTap: () => setState(() => _selectedCategory = 'Western'),
                icon: Icons.public,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return _TimelineItem(
                topic: topic,
                isFirst: index == 0,
                isLast: index == topics.length - 1,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _CategoryButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.goldTileGradient : null,
            color: isSelected ? null : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.black : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _ContentTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryGold : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryGold : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final _HistoryTopic topic;
  final String contentType;
  final int index;

  const _TopicCard({
    required this.topic,
    required this.contentType,
    required this.index,
  });

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  topic.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primaryGold.withValues(alpha: 0.2),
                    child: const Center(
                      child: Icon(
                        Icons.history_edu,
                        size: 40,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      topic.era,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topic.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (contentType == 'Videos')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(topic.videoUrl),
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Watch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(topic.documentUrl),
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _copyToClipboard(
                        context,
                        contentType == 'Videos'
                            ? topic.videoUrl
                            : topic.documentUrl,
                      ),
                      icon: const Icon(Icons.share),
                      tooltip: 'Share',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade().slideX(
      begin: 0.05,
      end: 0,
      delay: Duration(milliseconds: index * 100),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final _HistoryTopic topic;
  final bool isFirst;
  final bool isLast;
  final int index;

  const _TimelineItem({
    required this.topic,
    required this.isFirst,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 20, color: AppColors.primaryGold),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.primaryGold.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.era,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade().slideX(
      begin: 0.1,
      end: 0,
      delay: Duration(milliseconds: index * 100),
    );
  }
}

class _HistoryTopic {
  final String title;
  final String description;
  final String videoUrl;
  final String documentUrl;
  final String era;
  final String imageUrl;

  _HistoryTopic({
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.documentUrl,
    required this.era,
    required this.imageUrl,
  });
}

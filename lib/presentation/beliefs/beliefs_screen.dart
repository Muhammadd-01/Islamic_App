import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class BeliefsScreen extends ConsumerStatefulWidget {
  const BeliefsScreen({super.key});

  @override
  ConsumerState<BeliefsScreen> createState() => _BeliefsScreenState();
}

class _BeliefsScreenState extends ConsumerState<BeliefsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  String _selectedContentType = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'All', 'icon': Icons.list, 'color': Colors.grey},
    {
      'id': 'atheism',
      'name': 'Atheism',
      'icon': Icons.close,
      'color': Colors.red,
    },
    {
      'id': 'agnosticism',
      'name': 'Agnosticism',
      'icon': Icons.help_outline,
      'color': Colors.orange,
    },
    {
      'id': 'deism',
      'name': 'Deism',
      'icon': Icons.brightness_5,
      'color': Colors.blue,
    },
    {
      'id': 'humanism',
      'name': 'Secular Humanism',
      'icon': Icons.people,
      'color': Colors.green,
    },
    {
      'id': 'nihilism',
      'name': 'Nihilism',
      'icon': Icons.blur_on,
      'color': Colors.purple,
    },
  ];

  // Sample data - in production this comes from Firebase
  final List<Map<String, dynamic>> _beliefs = [
    {
      'id': '1',
      'name': 'What is Atheism?',
      'description':
          'Understanding the philosophical position of atheism and its arguments.',
      'category': 'atheism',
      'contentType': 'video',
      'videoUrl': 'https://www.youtube.com/watch?v=example',
    },
    {
      'id': '2',
      'name': 'Agnosticism Explained',
      'description':
          'The agnostic position: neither believing nor disbelieving in God.',
      'category': 'agnosticism',
      'contentType': 'video',
      'videoUrl': 'https://www.youtube.com/watch?v=example',
    },
    {
      'id': '3',
      'name': 'Islamic Response to Atheism',
      'description':
          'A scholarly paper discussing Islamic responses to atheist arguments.',
      'category': 'atheism',
      'contentType': 'document',
      'documentUrl': 'https://example.com/document.pdf',
    },
    {
      'id': '4',
      'name': 'Deism vs Theism',
      'description': 'Understanding the difference between deism and theism.',
      'category': 'deism',
      'contentType': 'video',
      'videoUrl': 'https://www.youtube.com/watch?v=example',
    },
    {
      'id': '5',
      'name': 'Secular Humanism Overview',
      'description':
          'An introduction to secular humanist philosophy and ethics.',
      'category': 'humanism',
      'contentType': 'document',
      'documentUrl': 'https://example.com/humanism.pdf',
    },
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

  List<Map<String, dynamic>> get _filteredBeliefs {
    return _beliefs.where((item) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          item['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['description'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesCategory =
          _selectedCategory == 'all' || item['category'] == _selectedCategory;
      final matchesType =
          _selectedContentType == 'all' ||
          item['contentType'] == _selectedContentType;
      return matchesSearch && matchesCategory && matchesType;
    }).toList();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beliefs & Worldviews'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryGold,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBrowseView(), _buildAboutView()],
      ),
    );
  }

  Widget _buildBrowseView() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search beliefs...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Category Filter
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(cat['name']),
                  avatar: Icon(
                    cat['icon'],
                    size: 16,
                    color: isSelected ? Colors.white : cat['color'],
                  ),
                  selectedColor: cat['color'],
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat['id']),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Content Type Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _ContentTypeButton(
                label: 'All',
                isSelected: _selectedContentType == 'all',
                onTap: () => setState(() => _selectedContentType = 'all'),
              ),
              const SizedBox(width: 8),
              _ContentTypeButton(
                label: 'Videos',
                icon: Icons.play_circle,
                isSelected: _selectedContentType == 'video',
                onTap: () => setState(() => _selectedContentType = 'video'),
              ),
              const SizedBox(width: 8),
              _ContentTypeButton(
                label: 'Documents',
                icon: Icons.description,
                isSelected: _selectedContentType == 'document',
                onTap: () => setState(() => _selectedContentType = 'document'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Content List
        Expanded(
          child: _filteredBeliefs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No content found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredBeliefs.length,
                  itemBuilder: (context, index) {
                    final item = _filteredBeliefs[index];
                    return _BeliefCard(
                      item: item,
                      categories: _categories,
                      onTap: () {
                        final url = item['contentType'] == 'video'
                            ? item['videoUrl']
                            : item['documentUrl'];
                        if (url != null && url.isNotEmpty) {
                          _openUrl(url);
                        }
                      },
                    ).animate().fade(delay: Duration(milliseconds: index * 50));
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAboutView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold,
                  AppColors.primaryGold.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 40, color: Colors.black54),
                SizedBox(height: 12),
                Text(
                  'Understanding Different Worldviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This section provides educational content about various belief systems and worldviews to help you understand different perspectives.',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ..._categories
              .skip(1)
              .map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (cat['color'] as Color).withValues(
                        alpha: 0.2,
                      ),
                      child: Icon(cat['icon'], color: cat['color']),
                    ),
                    title: Text(
                      cat['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_getCategoryDescription(cat['id'])),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  String _getCategoryDescription(String id) {
    switch (id) {
      case 'atheism':
        return 'The absence of belief in the existence of deities.';
      case 'agnosticism':
        return 'The view that the existence of God is unknown or unknowable.';
      case 'deism':
        return 'Belief in a creator who does not intervene in the universe.';
      case 'humanism':
        return 'A philosophical stance emphasizing human values without religion.';
      case 'nihilism':
        return 'The rejection of all religious and moral principles.';
      default:
        return '';
    }
  }
}

class _ContentTypeButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContentTypeButton({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : Theme.of(context).cardColor,
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
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : Colors.grey,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeliefCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final List<Map<String, dynamic>> categories;
  final VoidCallback onTap;

  const _BeliefCard({
    required this.item,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = categories.firstWhere(
      (c) => c['id'] == item['category'],
      orElse: () => {
        'name': 'Other',
        'color': Colors.grey,
        'icon': Icons.category,
      },
    );

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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['contentType'] == 'video'
                      ? Icons.play_circle
                      : Icons.description,
                  color: category['color'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
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
                        color: (category['color'] as Color).withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 10,
                          color: category['color'],
                          fontWeight: FontWeight.bold,
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

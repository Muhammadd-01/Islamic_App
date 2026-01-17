import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Politics Screen - Islamic and Western Political Content
class PoliticsScreen extends ConsumerStatefulWidget {
  const PoliticsScreen({super.key});

  @override
  ConsumerState<PoliticsScreen> createState() => _PoliticsScreenState();
}

class _PoliticsScreenState extends ConsumerState<PoliticsScreen>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Politics'),
        centerTitle: true,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIslamicPoliticsTab(isDark),
          _buildWesternPoliticsTab(isDark),
        ],
      ),
    );
  }

  Widget _buildIslamicPoliticsTab(bool isDark) {
    final topics = [
      _PoliticsTopic(
        'Caliphate System',
        'Understanding the historical Islamic governance model',
        Icons.account_balance,
        const Color(0xFF10B981),
      ),
      _PoliticsTopic(
        'Shura (Consultation)',
        'The Islamic principle of collective decision-making',
        Icons.groups,
        const Color(0xFF3B82F6),
      ),
      _PoliticsTopic(
        'Islamic Economics',
        'Principles of fair trade, zakat, and riba prohibition',
        Icons.monetization_on,
        const Color(0xFFF59E0B),
      ),
      _PoliticsTopic(
        'Social Justice in Islam',
        'Rights of citizens, minorities, and social equality',
        Icons.balance,
        const Color(0xFF8B5CF6),
      ),
      _PoliticsTopic(
        'Contemporary Muslim Nations',
        'Political systems in modern Muslim-majority countries',
        Icons.public,
        const Color(0xFFEC4899),
      ),
      _PoliticsTopic(
        'Islamic Law & Governance',
        'Application of Shariah in state affairs',
        Icons.gavel,
        const Color(0xFF14B8A6),
      ),
    ];

    return _buildTopicsList(topics, isDark);
  }

  Widget _buildWesternPoliticsTab(bool isDark) {
    final topics = [
      _PoliticsTopic(
        'Democracy & Islam',
        'Comparing democratic principles with Islamic values',
        Icons.how_to_vote,
        const Color(0xFF3B82F6),
      ),
      _PoliticsTopic(
        'Secularism Analysis',
        'Understanding secular governance from an Islamic perspective',
        Icons.location_city,
        const Color(0xFF6366F1),
      ),
      _PoliticsTopic(
        'Human Rights',
        'Western human rights vs. Islamic conception of rights',
        Icons.people,
        const Color(0xFF10B981),
      ),
      _PoliticsTopic(
        'Global Politics',
        'Muslim world in international relations',
        Icons.public,
        const Color(0xFFEA580C),
      ),
      _PoliticsTopic(
        'Political Philosophy',
        'Comparing Western and Islamic political thought',
        Icons.psychology,
        const Color(0xFF8B5CF6),
      ),
      _PoliticsTopic(
        'Current Affairs',
        'Analysis of contemporary political events',
        Icons.newspaper,
        const Color(0xFFEF4444),
      ),
    ];

    return _buildTopicsList(topics, isDark);
  }

  Widget _buildTopicsList(List<_PoliticsTopic> topics, bool isDark) {
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
          child: ListTile(
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
              child: Icon(topic.icon, color: topic.color, size: 24),
            ),
            title: Text(
              topic.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              // TODO: Navigate to topic detail (connect to Firestore later)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${topic.title} - Coming Soon'),
                  backgroundColor: topic.color,
                ),
              );
            },
          ),
        ).animate(delay: (50 * index).ms).fade().slideX(begin: 0.1, end: 0);
      },
    );
  }
}

class _PoliticsTopic {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _PoliticsTopic(this.title, this.description, this.icon, this.color);
}

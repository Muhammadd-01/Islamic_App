import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// News item model
class NewsItem {
  final String title;
  final String description;
  final String url;
  final String source;
  final String? imageUrl;
  final String category;
  final DateTime publishedAt;

  NewsItem({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    this.imageUrl,
    this.category = 'general',
    required this.publishedAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      source: json['source'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      category: json['category'] ?? 'general',
      publishedAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// News provider - Fetches global news with thumbnails
final newsProvider = FutureProvider<List<NewsItem>>((ref) async {
  // Mock news data with images for demonstration
  return [
    NewsItem(
      title: 'Breaking: Major Technology Advancement in AI',
      description:
          'Scientists announce breakthrough in artificial intelligence research that could revolutionize industries worldwide.',
      url:
          'https://news.google.com/topics/CAAqIggKIhxDQkFTRHdvSkwyMHZNREZqYUdjd0VnSm9kQ2dBUAE',
      source: 'Tech Daily',
      imageUrl:
          'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400',
      category: 'technology',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NewsItem(
      title: 'Global Climate Summit Reaches Agreement',
      description:
          'World leaders agree on new climate goals at international summit, promising significant reductions in emissions.',
      url:
          'https://news.google.com/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRFp1ZEdvU0FtVnVHZ0pWVXlnQVAB',
      source: 'World News',
      imageUrl:
          'https://images.unsplash.com/photo-1569163139599-0f4517e36f51?w=400',
      category: 'world',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NewsItem(
      title: 'Economic Markets Show Strong Recovery',
      description:
          'Financial markets worldwide demonstrate resilience with positive growth indicators across major indexes.',
      url:
          'https://news.google.com/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGRqTVhZU0FtVnVHZ0pWVXlnQVAB',
      source: 'Finance Today',
      imageUrl:
          'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400',
      category: 'business',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    NewsItem(
      title: 'New Medical Breakthrough in Cancer Research',
      description:
          'Researchers announce promising results in early-stage trials for new cancer treatment methodology.',
      url:
          'https://news.google.com/topics/CAAqIQgKIhtDQkFTRGdvSUwyMHZNR3QwTlRFU0FtVnVLQUFQAQ',
      source: 'Health News',
      imageUrl:
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=400',
      category: 'health',
      publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    NewsItem(
      title: 'Space Exploration: New Mission Announced',
      description:
          'Space agency reveals plans for ambitious new mission to explore distant planets in our solar system.',
      url:
          'https://news.google.com/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRFZ4ZERBU0FtVnVHZ0pWVXlnQVAB',
      source: 'Space Times',
      imageUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400',
      category: 'science',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NewsItem(
      title: 'Islamic Heritage Month Celebrations Begin',
      description:
          'Communities worldwide begin celebrating Islamic heritage with cultural events and educational programs.',
      url: 'https://news.google.com',
      source: 'Islamic Times',
      imageUrl:
          'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=400',
      category: 'islamic',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
});

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global News'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(newsProvider),
          ),
        ],
      ),
      body: newsAsync.when(
        data: (news) {
          if (news.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.newspaper, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No news available'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
              return _NewsCard(item: item, isDark: isDark)
                  .animate(delay: (50 * index).ms)
                  .fade()
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(newsProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  final bool isDark;

  const _NewsCard({required this.item, required this.isDark});

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.parse(item.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open article')));
      }
    }
  }

  Color _getCategoryColor() {
    switch (item.category.toLowerCase()) {
      case 'technology':
        return const Color(0xFF3B82F6);
      case 'world':
        return const Color(0xFF10B981);
      case 'business':
        return const Color(0xFFF59E0B);
      case 'health':
        return const Color(0xFFEC4899);
      case 'science':
        return const Color(0xFF8B5CF6);
      case 'islamic':
        return AppColors.primaryGold;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openArticle(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              Stack(
                children: [
                  Image.network(
                    item.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      );
                    },
                  ),
                  // Category badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.source,
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(item.publishedAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    item.description,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Read more button
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Read More',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

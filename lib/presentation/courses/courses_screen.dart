import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Course model
class Course {
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final String level;
  final String imageUrl;
  final String enrollUrl;
  final bool isFree;
  final double? price;

  Course({
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.level,
    required this.imageUrl,
    required this.enrollUrl,
    this.isFree = false,
    this.price,
  });
}

/// Courses provider
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  // Mock courses - in production, fetch from Firebase
  return [
    Course(
      title: 'Introduction to Arabic',
      description:
          'Learn the fundamentals of Arabic language for Quran understanding',
      instructor: 'Sheikh Ahmad Al-Farooq',
      duration: '8 weeks',
      level: 'Beginner',
      imageUrl:
          'https://images.unsplash.com/photo-1579187707643-35646d22b596?w=400',
      enrollUrl: 'https://deen-sphere.vercel.app/courses/arabic',
      isFree: true,
    ),
    Course(
      title: 'Tajweed Masterclass',
      description: 'Perfect your Quran recitation with proper tajweed rules',
      instructor: 'Qari Muhammad Yusuf',
      duration: '12 weeks',
      level: 'Intermediate',
      imageUrl:
          'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=400',
      enrollUrl: 'https://deen-sphere.vercel.app/courses/tajweed',
      price: 49.99,
    ),
    Course(
      title: 'Islamic Fiqh Foundations',
      description: 'Understand the principles of Islamic jurisprudence',
      instructor: 'Dr. Bilal Philips',
      duration: '16 weeks',
      level: 'Advanced',
      imageUrl:
          'https://images.unsplash.com/photo-1585036156171-384164a8c675?w=400',
      enrollUrl: 'https://deen-sphere.vercel.app/courses/fiqh',
      price: 79.99,
    ),
    Course(
      title: 'Seerah of the Prophet ﷺ',
      description: 'A complete study of the life of Prophet Muhammad ﷺ',
      instructor: 'Sheikh Yasir Qadhi',
      duration: '20 weeks',
      level: 'All Levels',
      imageUrl:
          'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=400',
      enrollUrl: 'https://deen-sphere.vercel.app/courses/seerah',
      isFree: true,
    ),
    Course(
      title: 'Islamic Finance & Economics',
      description:
          'Learn halal financial principles and modern Islamic banking',
      instructor: 'Dr. Mufti Taqi Usmani',
      duration: '10 weeks',
      level: 'Intermediate',
      imageUrl:
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400',
      enrollUrl: 'https://deen-sphere.vercel.app/courses/finance',
      price: 99.99,
    ),
  ];
});

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  static const String deenSphereUrl = 'https://deen-sphere.vercel.app/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses & Scholarships'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchUrl(deenSphereUrl, context),
            tooltip: 'Visit Website',
          ),
        ],
      ),
      body: coursesAsync.when(
        data: (courses) {
          return Column(
            children: [
              // Website banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold,
                      AppColors.primaryGold.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Colors.black, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DeenSphere Academy',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap any course to enroll on our website',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                      ),
                      onPressed: () => _launchUrl(deenSphereUrl, context),
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: -0.1, end: 0),
              // Courses list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _CourseCard(
                      course: course,
                      index: index,
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],
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
                onPressed: () => ref.refresh(coursesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open website')));
      }
    }
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final int index;
  final bool isDark;

  const _CourseCard({
    required this.course,
    required this.index,
    required this.isDark,
  });

  Future<void> _enrollInCourse(BuildContext context) async {
    final Uri uri = Uri.parse(course.enrollUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open enrollment page')),
        );
      }
    }
  }

  Color _getLevelColor() {
    switch (course.level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF10B981);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _enrollInCourse(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image
            Stack(
              children: [
                Image.network(
                  course.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: const Center(child: Icon(Icons.school, size: 48)),
                  ),
                ),
                // Price badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: course.isFree
                          ? Colors.green
                          : AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.isFree ? 'FREE' : '\$${course.price}',
                      style: TextStyle(
                        color: course.isFree ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Level badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.level,
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
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Course info
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          course.instructor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        course.duration,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Enroll button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _enrollInCourse(context),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Enroll Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0, delay: (80 * index).ms);
  }
}

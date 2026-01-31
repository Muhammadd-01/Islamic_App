import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamic_app/data/repositories/enrollment_repository.dart';
import 'package:islamic_app/core/providers/user_provider.dart';

/// Course model
// (Course class remains same)
class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final String level;
  final String imageUrl;
  final String enrollUrl;
  final bool isFree;
  final double? price;
  final int minAge;
  final String academicCriteria;
  final bool hasCertification;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.level,
    required this.imageUrl,
    required this.enrollUrl,
    this.isFree = false,
    this.price,
    this.minAge = 0,
    this.academicCriteria = '',
    this.hasCertification = false,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructor: map['instructor'] ?? '',
      duration: map['duration'] ?? '',
      level: map['level'] ?? 'Beginner',
      imageUrl: map['imageUrl'] ?? '',
      enrollUrl: map['enrollUrl'] ?? '',
      isFree: map['isFree'] ?? false,
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : null,
      minAge: map['minAge'] ?? 0,
      academicCriteria: map['academicCriteria'] ?? '',
      hasCertification: map['hasCertification'] ?? false,
    );
  }
}

/// Courses provider - fetches from Firebase
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .get();
    if (snapshot.docs.isEmpty) {
      // Return some default courses if none exist
      return _getDefaultCourses();
    }
    return snapshot.docs
        .map((doc) => Course.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    print('Error fetching courses: $e');
    // Return default courses on error
    return _getDefaultCourses();
  }
});

List<Course> _getDefaultCourses() {
  return [
    Course(
      id: 'default_1',
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
      id: 'default_2',
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
      id: 'default_3',
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
  ];
}

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

  void _showPaymentSheet(
    BuildContext context,
    Course course,
    Function(String transactionId) onPaymentSuccess,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Secure Payment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are paying \$${course.price} for ${course.title}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Card Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: '**** **** **** 4242',
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '12/25',
                    decoration: InputDecoration(
                      labelText: 'Expiry',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: '***',
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPaymentSuccess(
                    'txn_${DateTime.now().millisecondsSinceEpoch}',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showEnrollmentForm(BuildContext context, Course course, WidgetRef ref) {
    final userProfile = ref.read(userProfileProvider).value;

    final nameController = TextEditingController(text: userProfile?.name ?? '');
    final emailController = TextEditingController(
      text: userProfile?.email ?? '',
    );
    final phoneController = TextEditingController(
      text: userProfile?.phone ?? '',
    );
    final ageController = TextEditingController();
    final qualificationController = TextEditingController();
    final commentsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    String? selectedPaymentMethod;
    final paymentMethods = [
      'Credit/Debit Card',
      'Bank Transfer',
      'JazzCash/EasyPaisa',
      'PayPal',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (stateContext, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(stateContext).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(stateContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Enroll in ${course.title}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(stateContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please confirm your details to request enrollment. Our team will contact you soon.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    if (course.minAge > 0 ||
                        course.academicCriteria.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: ageController,
                              decoration: InputDecoration(
                                labelText: 'Age',
                                prefixIcon: const Icon(Icons.cake),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                final age = int.tryParse(value!);
                                if (age == null) return 'Invalid';
                                if (age < 1) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: qualificationController,
                              decoration: InputDecoration(
                                labelText: 'Academic Qualification',
                                prefixIcon: const Icon(Icons.school),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!course.isFree) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        decoration: InputDecoration(
                          labelText: 'Select Payment Method',
                          prefixIcon: const Icon(Icons.payment),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: paymentMethods
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedPaymentMethod = val),
                        validator: (value) => value == null
                            ? 'Please select a payment method'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: commentsController,
                      decoration: InputDecoration(
                        labelText: 'Additional Comments (Optional)',
                        prefixIcon: const Icon(Icons.comment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    if (!course.isFree) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Course Fee:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${course.price}',
                              style: const TextStyle(
                                color: Color(0xFFB8860B),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '* Payment is required to complete enrollment.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  if (!course.isFree) {
                                    // If paid, show payment sheet first
                                    _showPaymentSheet(stateContext, course, (
                                      txnId,
                                    ) async {
                                      setState(() => isSubmitting = true);
                                      try {
                                        await ref
                                            .read(enrollmentRepositoryProvider)
                                            .submitEnrollment(
                                              courseId: course.id,
                                              courseTitle: course.title,
                                              userName: nameController.text,
                                              userEmail: emailController.text,
                                              phone: phoneController.text,
                                              comments: commentsController.text,
                                              paymentStatus: 'paid',
                                              age: int.parse(
                                                ageController.text,
                                              ),
                                              qualification:
                                                  qualificationController.text,
                                              paymentMethod:
                                                  selectedPaymentMethod,
                                              amountPaid: course.price,
                                              transactionId: txnId,
                                            );
                                        if (stateContext.mounted) {
                                          Navigator.pop(
                                            stateContext,
                                          ); // Close form
                                          ScaffoldMessenger.of(
                                            stateContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Enrollment successful!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (stateContext.mounted) {
                                          ScaffoldMessenger.of(
                                            stateContext,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (stateContext.mounted) {
                                          setState(() => isSubmitting = false);
                                        }
                                      }
                                    });
                                  } else {
                                    // If free, submit immediately
                                    setState(() => isSubmitting = true);
                                    try {
                                      await ref
                                          .read(enrollmentRepositoryProvider)
                                          .submitEnrollment(
                                            courseId: course.id,
                                            courseTitle: course.title,
                                            userName: nameController.text,
                                            userEmail: emailController.text,
                                            phone: phoneController.text,
                                            comments: commentsController.text,
                                            paymentStatus: 'free',
                                            age:
                                                int.tryParse(
                                                  ageController.text,
                                                ) ??
                                                0,
                                            qualification:
                                                qualificationController
                                                    .text
                                                    .isEmpty
                                                ? 'No Criteria'
                                                : qualificationController.text,
                                          );
                                      if (stateContext.mounted) {
                                        Navigator.pop(stateContext);
                                        ScaffoldMessenger.of(
                                          stateContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Enrollment request submitted!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (stateContext.mounted) {
                                        ScaffoldMessenger.of(
                                          stateContext,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    } finally {
                                      if (stateContext.mounted) {
                                        setState(() => isSubmitting = false);
                                      }
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                course.isFree
                                    ? 'Submit Request'
                                    : 'Proceed to Payment',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  final Course course;
  final int index;
  final bool isDark;

  const _CourseCard({
    required this.course,
    required this.index,
    required this.isDark,
  });

  void _enrollInCourse(BuildContext context, WidgetRef ref) {
    (context.findAncestorWidgetOfExactType<CoursesScreen>() as CoursesScreen)
        ._showEnrollmentForm(context, course, ref);
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _enrollInCourse(context, ref),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.duration,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Criteria & Certification
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: AppColors.primaryGold,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    (course.minAge <= 0 &&
                                            course.academicCriteria.isEmpty)
                                        ? 'No criteria'
                                        : [
                                            if (course.minAge > 0)
                                              'Min Age: ${course.minAge}',
                                            if (course
                                                .academicCriteria
                                                .isNotEmpty)
                                              course.academicCriteria,
                                          ].join(' • '),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                      fontStyle:
                                          (course.minAge <= 0 &&
                                              course.academicCriteria.isEmpty)
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (course.hasCertification)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.primaryGold.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 10,
                                color: AppColors.primaryGold,
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                'Certified',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Enroll button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _enrollInCourse(context, ref),
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

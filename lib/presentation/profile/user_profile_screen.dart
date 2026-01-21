import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/providers/user_provider.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';
import 'package:islamic_app/data/repositories/bookmark_repository.dart';

// Global userProfileProvider is imported from user_provider.dart

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.value;
    final profileAsync = ref.watch(userProfileProvider);
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);

    // Get user data from Firestore profile
    final profile = profileAsync.value;
    final profileImageUrl = profile?.imageUrl ?? user?.imageUrl;
    final displayName = profile?.name ?? user?.name ?? 'User';

    // Real bookmark count
    final totalBookmarks = bookmarksAsync.value?.length ?? 0;

    // Mock last read for now (needs Quran tracking implementation)
    const lastReadSurah = 'Al-Kahf';
    const lastReadAyah = 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar (view only - edit in Edit Profile screen)
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGoldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child:
                          profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stack) =>
                                  Container(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.primary,
                                    ),
                                  ),
                            )
                          : Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ).animate().fade().slideY(begin: 0.5, end: 0, delay: 100.ms),
            Text(
              user?.email ?? '',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ).animate().fade().slideY(begin: 0.5, end: 0, delay: 200.ms),
            const SizedBox(height: 32),
            _buildStatsCard(
              totalBookmarks,
              lastReadSurah,
              lastReadAyah,
            ).animate().fade().slideX(begin: 0.2, end: 0, delay: 300.ms),
            const SizedBox(height: 32),
            Column(
              children:
                  [
                        _buildMenuButton(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          onTap: () => context.push('/notifications'),
                        ),
                        _buildMenuButton(
                          icon: Icons.lock_reset,
                          title: 'Change Password',
                          onTap: () => context.push('/forgot-password'),
                        ),
                        _buildMenuButton(
                          icon: Icons.bookmark,
                          title: 'Bookmarks',
                          onTap: () => context.push('/bookmarks'),
                        ),
                        _buildMenuButton(
                          icon: Icons.shopping_bag,
                          title: 'My Orders',
                          onTap: () => context.push('/my-orders'),
                        ),
                        _buildMenuButton(
                          icon: Icons.logout,
                          title: 'Logout',
                          isDestructive: true,
                          onTap: () async {
                            // Show loading indicator for immediate feedback
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              await ref.read(authRepositoryProvider).signOut();
                            } finally {
                              // Use root navigator to pop dialog if still mounted
                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop(); // Pop dialog
                                context.go('/login');
                              }
                            }
                          },
                        ),
                      ]
                      .animate(interval: 100.ms)
                      .fade()
                      .slideX(begin: 0.1, end: 0, delay: 400.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int bookmarks, String surah, int ayah) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Bookmarks', bookmarks.toString()),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildStatItem('Last Read', '$surah : $ayah'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
            fontSize: 15,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

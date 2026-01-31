import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/providers/user_provider.dart';
import 'package:islamic_app/data/services/supabase_service.dart';
import 'package:islamic_app/data/services/location_service.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';
import 'package:islamic_app/presentation/auth/auth_provider.dart';
import 'package:islamic_app/presentation/widgets/country_code_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  CountryCode _selectedCountry = CountryCodeDropdown.countries[0];
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userRepo = ref.read(userRepositoryProvider);
    final userData = await userRepo.getUserData();
    if (userData != null && mounted) {
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        _locationController.text = userData['location'] ?? '';

        final phone = userData['phone'] as String?;
        if (phone != null && phone.isNotEmpty) {
          // Attempt to match country code
          for (var c in CountryCodeDropdown.countries) {
            if (phone.startsWith(c.code)) {
              _selectedCountry = c;
              _phoneController.text = phone.substring(c.code.length);
              break;
            }
          }
          if (_phoneController.text.isEmpty) {
            _phoneController.text = phone;
          }
        }
        _currentImageUrl = userData['imageUrl'];
      });
    }
  }

  bool get _hasImage =>
      _selectedImage != null ||
      (_currentImageUrl != null && _currentImageUrl!.isNotEmpty);

  Future<void> _handleImageTap() async {
    if (!_hasImage) {
      await _pickImage();
    } else {
      await _showImageOptionsDialog();
    }
  }

  Future<void> _showImageOptionsDialog() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Change Image'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Remove Image',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedImage = null;
                  _selectedImageBytes = null;
                  _currentImageUrl = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final locationService = LocationService();
      final locationString = await locationService.getLocationString();
      setState(() {
        _locationController.text = locationString;
      });
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to get location: $e');
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final authState = ref.read(authStateProvider);
      final user = authState.value;

      String? imageUrl = _currentImageUrl;

      // Upload image to Supabase if new image selected
      if (_selectedImageBytes != null &&
          _selectedImage != null &&
          user != null) {
        final supabaseService = SupabaseService();
        imageUrl = await supabaseService.updateProfileImage(
          user.uid,
          _selectedImageBytes!,
          _selectedImage!.name,
          _currentImageUrl,
        );
      }

      await userRepo.updateUserProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        imageUrl: imageUrl,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : '${_selectedCountry.code}${_phoneController.text.trim()}',
      );

      if (mounted) {
        AppSnackbar.showSuccess(context, 'Profile updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to update profile: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: _selectedImageBytes != null
                      ? MemoryImage(_selectedImageBytes!)
                      : (_currentImageUrl != null &&
                                    _currentImageUrl!.isNotEmpty
                                ? NetworkImage(_currentImageUrl!)
                                : null)
                            as ImageProvider?,
                  child:
                      _selectedImageBytes == null &&
                          (_currentImageUrl == null ||
                              _currentImageUrl!.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _handleImageTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _hasImage ? Icons.edit : Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: _isLoadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _detectLocation,
                        tooltip: 'Detect Location',
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Phone Row (Dropdown + Input)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountryCodeDropdown(
                  selectedCountry: _selectedCountry,
                  onSelected: (country) =>
                      setState(() => _selectedCountry = country),
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

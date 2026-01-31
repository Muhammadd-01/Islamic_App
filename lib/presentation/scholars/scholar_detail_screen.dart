import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/domain/entities/scholar.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/core/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:islamic_app/core/constants/api_constants.dart';
import 'package:islamic_app/data/services/api_config_service.dart';
import 'dart:convert';

class ScholarDetailScreen extends ConsumerStatefulWidget {
  final Scholar scholar;

  const ScholarDetailScreen({super.key, required this.scholar});

  @override
  ConsumerState<ScholarDetailScreen> createState() =>
      _ScholarDetailScreenState();
}

class _ScholarDetailScreenState extends ConsumerState<ScholarDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.scholar.name),
              background: Hero(
                tag: 'scholar_${widget.scholar.id}',
                child: Image.network(
                  widget.scholar.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 100),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.scholar.specialty,
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.scholar.isAvailableFor1on1)
                        Row(
                          children: [
                            const Icon(Icons.videocam, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '\$${widget.scholar.consultationFee.toInt()}/hr',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Biography',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.scholar.bio,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (widget.scholar.isAvailableFor1on1)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.scholar.isBooked
                            ? null
                            : () => _showBookingDialog(context),
                        icon: Icon(
                          widget.scholar.isBooked
                              ? Icons.lock_clock
                              : Icons.calendar_today,
                        ),
                        label: Text(
                          widget.scholar.isBooked
                              ? 'Session Fully Booked'
                              : 'Book Live Session',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: widget.scholar.isBooked
                              ? Colors.grey
                              : AppColors.primaryGold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ).animate().fade().scale(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BookingSheet(scholar: widget.scholar),
    );
  }
}

class _BookingSheet extends ConsumerStatefulWidget {
  final Scholar scholar;

  const _BookingSheet({required this.scholar});

  @override
  ConsumerState<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends ConsumerState<_BookingSheet> {
  DateTime? _selectedDate;
  String? _selectedTime;
  String _paymentMethod = 'card';
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isProcessing = false;

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill user details if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider).value;
      if (userProfile != null) {
        setState(() {
          _nameController.text = userProfile.name ?? '';
          _emailController.text = userProfile.email;
          if (userProfile.phone != null && userProfile.phone!.isNotEmpty) {
            _phoneController.text = userProfile.phone!;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGold,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _processBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      AppSnackbar.showError(context, 'Please select date and time');
      return;
    }
    if (_nameController.text.isEmpty) {
      AppSnackbar.showError(context, 'Please enter your name');
      return;
    }
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      AppSnackbar.showError(context, 'Please enter a valid email');
      return;
    }
    if (_phoneController.text.isEmpty) {
      AppSnackbar.showError(context, 'Please enter WhatsApp number');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final userProfile = ref.read(userProfileProvider).value;
      final userId = userProfile?.uid ?? 'anonymous_user';
      final dynamicBaseUrl = ref.read(apiUrlProvider);

      // 1. Call Backend API for Booking
      final response = await http.post(
        Uri.parse(ApiConstants.getBookingsUrl(dynamicBaseUrl)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'scholarId': widget.scholar.id,
          'scholarName': widget.scholar.name,
          'userId': userId,
          'userName': _nameController.text,
          'userEmail': _emailController.text,
          'userPhone': _phoneController.text,
          'dateTime':
              '${DateFormat('yyyy-MM-dd').format(_selectedDate!)} at $_selectedTime',
          'fee': widget.scholar.consultationFee,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create booking: ${response.body}');
      }

      final formattedDate = DateFormat(
        'EEEE, MMMM d, yyyy',
      ).format(_selectedDate!);
      final sessionDetails =
          '''
📅 Session Booked Successfully!

Scholar: ${widget.scholar.name}
Date: $formattedDate
Time: $_selectedTime

Your session is confirmed. Our backend has automatically notified ${widget.scholar.name}.
''';

      setState(() => _isProcessing = false);

      if (mounted) {
        Navigator.pop(context);
        _showConfirmationDialog(sessionDetails);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to book session: $e');
      }
    }
  }

  void _showConfirmationDialog(String details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Text('Booking Confirmed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 16),
            const Text(
              'A notification has been sent to the scholar via WhatsApp.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: details));
              Navigator.pop(context);
              AppSnackbar.showSuccess(context, 'Details copied to clipboard!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.black,
            ),
            child: const Text('Done & Copy Details'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.scholar.imageUrl),
                radius: 25,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Session with',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      widget.scholar.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${widget.scholar.consultationFee.toInt()}/hr',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selection
                  const Text(
                    'Select Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedDate != null
                              ? AppColors.primaryGold
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _selectedDate != null
                                ? AppColors.primaryGold
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? DateFormat(
                                    'EEEE, MMM d, yyyy',
                                  ).format(_selectedDate!)
                                : 'Tap to select date',
                            style: TextStyle(
                              color: _selectedDate != null ? null : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time Selection
                  const Text(
                    'Select Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = time),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGold
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGold
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? Colors.black : null,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Contact Info
                  const Text(
                    'Your Information',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Confirmation will be sent here',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'WhatsApp Number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Include country code (e.g., +1234567890)',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Method
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _PaymentOption(
                          icon: Icons.credit_card,
                          label: 'Card',
                          isSelected: _paymentMethod == 'card',
                          onTap: () => setState(() => _paymentMethod = 'card'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PaymentOption(
                          icon: Icons.paypal,
                          label: 'PayPal',
                          isSelected: _paymentMethod == 'paypal',
                          onTap: () =>
                              setState(() => _paymentMethod = 'paypal'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Book Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      'Pay \$${widget.scholar.consultationFee.toInt()} & Confirm',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryGold : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : null,
                color: isSelected ? AppColors.primaryGold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

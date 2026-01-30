import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/providers/user_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'Easypaisa';
  bool _isSubmitting = false;
  bool _isLoadingSettings = true;

  Map<String, Map<String, dynamic>> _paymentDetails = {
    'Bank Transfer': {
      'Account': 'Loading...',
      'Number': 'Loading...',
      'Bank': 'Loading...',
      'IBAN': 'Loading...',
    },
    'PayPal': {'Email': 'Loading...'},
    'Easypaisa': {'Number': 'Loading...', 'Name': 'Loading...'},
    'JazzCash': {'Number': 'Loading...', 'Name': 'Loading...'},
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('donations')
          .get();

      if (doc.exists && mounted) {
        setState(() {
          final data = doc.data() as Map<String, dynamic>;
          // Update each method if data exists in Firestore
          data.forEach((method, details) {
            if (_paymentDetails.containsKey(method)) {
              _paymentDetails[method] = Map<String, dynamic>.from(details);
            }
          });
          _isLoadingSettings = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingSettings = false);
      }
    } catch (e) {
      debugPrint('Error loading donation settings: $e');
      if (mounted) setState(() => _isLoadingSettings = false);
    }
  }

  Future<void> _submitDonation() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(userProfileProvider).value;

      await FirebaseFirestore.instance.collection('donations').add({
        'userId': user?.uid ?? 'anonymous',
        'userName': user?.name ?? 'Anonymous User',
        'userEmail': user?.email ?? 'N/A',
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'method': _selectedMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending Verification',
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('JazakAllah Khair!'),
            content: const Text(
              'Your donation record has been submitted. We will verify it shortly.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Support Our Cause'), elevation: 0),
      body: _isLoadingSettings
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldTileGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sadaqah Jariyah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Help us keep DeenSphere free for everyone.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  const Text(
                    'Donation Amount',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixIcon: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.grey[100],
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _paymentDetails.keys.map((method) {
                      final isSelected = _selectedMethod == method;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMethod = method),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGold.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGold
                                  : Colors.grey.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            method,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primaryGold
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_selectedMethod Details',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.primaryGold,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        ..._paymentDetails[_selectedMethod]!.entries.map((
                          entry,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      entry.value.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 16),
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: entry.value.toString(),
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Copied to clipboard',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        if (_selectedMethod != 'PayPal') ...[
                          const Divider(height: 32),
                          const Text(
                            'Scan to Pay',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Image.network(
                                    'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent('$_selectedMethod: ' + (_paymentDetails[_selectedMethod]?['Number']?.toString() ?? _paymentDetails[_selectedMethod]?['IBAN']?.toString() ?? 'No Details'))}',
                                    width: 150,
                                    height: 150,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.qr_code,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                  ),
                                ),
                              )
                              .animate(key: ValueKey(_selectedMethod))
                              .scale(
                                duration: 400.ms,
                                curve: Curves.easeOutBack,
                              )
                              .fadeIn(duration: 400.ms),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit Donation Record',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Note: Please transfer the amount first, then submit this record for verification.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

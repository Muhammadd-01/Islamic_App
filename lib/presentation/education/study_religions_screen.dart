import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class StudyReligionsScreen extends StatelessWidget {
  const StudyReligionsScreen({super.key});

  final List<Map<String, String>> _religions = const [
    {
      "name": "Christianity",
      "description": "Based on the life and teachings of Jesus of Nazareth.",
      "icon": "✝️",
    },
    {
      "name": "Judaism",
      "description": "The monotheistic religion of the Jewish people.",
      "icon": "✡️",
    },
    {
      "name": "Hinduism",
      "description": "An Indian religion or dharma, a way of life.",
      "icon": "🕉️",
    },
    {
      "name": "Buddhism",
      "description": "A path of practice and spiritual development.",
      "icon": "☸️",
    },
    {
      "name": "Sikhism",
      "description": "A monotheistic religion founded in Punjab.",
      "icon": "☬",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparative Religion')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _religions.length,
        itemBuilder: (context, index) {
          final religion = _religions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  religion['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              title: Text(
                religion['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(religion['description']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to detail screen (placeholder for now)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${religion['name']} resources...'),
                  ),
                );
              },
            ),
          ).animate().fade().slideX(delay: (50 * index).ms, begin: 0.1, end: 0);
        },
      ),
    );
  }
}

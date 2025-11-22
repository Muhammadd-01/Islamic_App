import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class NamesOfAllahScreen extends StatelessWidget {
  const NamesOfAllahScreen({super.key});

  final List<Map<String, String>> _names = const [
    {"name": "Allah", "meaning": "The Greatest Name", "arabic": "الله"},
    {
      "name": "Ar-Rahman",
      "meaning": "The All-Compassionate",
      "arabic": "الرحمن",
    },
    {"name": "Ar-Rahim", "meaning": "The All-Merciful", "arabic": "الرحيم"},
    {"name": "Al-Malik", "meaning": "The King", "arabic": "الملك"},
    {"name": "Al-Quddus", "meaning": "The Holy", "arabic": "القدوس"},
    {"name": "As-Salam", "meaning": "The Source of Peace", "arabic": "السلام"},
    {
      "name": "Al-Mu'min",
      "meaning": "The Guardian of Faith",
      "arabic": "المؤمن",
    },
    {"name": "Al-Muhaymin", "meaning": "The Protector", "arabic": "المهيمن"},
    {"name": "Al-Aziz", "meaning": "The Mighty", "arabic": "العزيز"},
    {"name": "Al-Jabbar", "meaning": "The Compeller", "arabic": "الجبار"},
    // Add more names here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('99 Names of Allah')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _names.length,
        itemBuilder: (context, index) {
          final name = _names[index];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name['arabic']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'Amiri', // Assuming a calligraphy font is available or default
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name['meaning']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fade(duration: 400.ms, delay: (50 * index).ms).scale();
        },
      ),
    );
  }
}

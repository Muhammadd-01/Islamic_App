import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class DebatePanelScreen extends StatelessWidget {
  const DebatePanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debate Panel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDebateTopic(
            context,
            "The Concept of God",
            "Monotheism vs Polytheism",
            "120 Active Discussions",
            Colors.blue,
          ),
          _buildDebateTopic(
            context,
            "Prophethood",
            "Characteristics of Prophets",
            "85 Active Discussions",
            Colors.green,
          ),
          _buildDebateTopic(
            context,
            "Scripture Analysis",
            "Quran and Previous Books",
            "200 Active Discussions",
            Colors.orange,
          ),
          _buildDebateTopic(
            context,
            "Science & Religion",
            "Compatibility and Miracles",
            "150 Active Discussions",
            Colors.purple,
          ),
        ].animate(interval: 100.ms).fade().slideY(begin: 0.1, end: 0),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Start New Debate feature coming soon!'),
            ),
          );
        },
        label: const Text('New Topic'),
        icon: const Icon(Icons.add_comment),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDebateTopic(
    BuildContext context,
    String title,
    String subtitle,
    String stats,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Joining $title...')));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stats,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

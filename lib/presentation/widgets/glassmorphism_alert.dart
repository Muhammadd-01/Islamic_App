import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlassmorphismAlert extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? iconColor;

  const GlassmorphismAlert({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
    this.icon,
    this.iconColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GlassmorphismAlert(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child:
          ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (iconColor ?? Colors.red).withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 48,
                              color: iconColor ?? Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onPressed?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(buttonText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .fade(duration: 300.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
    );
  }
}

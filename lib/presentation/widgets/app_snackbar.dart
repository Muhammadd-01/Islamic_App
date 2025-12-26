import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _SnackbarOverlay(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );

    overlay.insert(overlayEntry);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.error);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.info);
  }
}

class _SnackbarOverlay extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final Duration duration;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _SnackbarOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<_SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<_SnackbarOverlay>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (mounted && _isVisible) {
      setState(() => _isVisible = false);
      Future.delayed(300.ms, widget.onDismiss);
    }
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case SnackbarType.success:
        return AppColors.primary;
      case SnackbarType.error:
        return const Color(0xFFEF4444);
      case SnackbarType.warning:
        return AppColors.accent;
      case SnackbarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case SnackbarType.warning:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomPadding + 100, // Above nav bar
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: 300.ms,
        child: AnimatedSlide(
          offset: _isVisible ? Offset.zero : const Offset(0, 0.5),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
          child:
              Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: _dismiss,
                      onHorizontalDragEnd: (_) => _dismiss(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _backgroundColor,
                                  _backgroundColor.withValues(alpha: 0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _backgroundColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _icon,
                                    color: _textColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.message,
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (widget.actionLabel != null) ...[
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () {
                                      widget.onAction?.call();
                                      _dismiss();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: _textColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      widget.actionLabel!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _dismiss,
                                  child: Icon(
                                    Icons.close,
                                    color: _textColor.withValues(alpha: 0.7),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate(target: _isVisible ? 1 : 0)
                  .slideY(
                    begin: 1,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fade(duration: 300.ms),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_avatar.dart';

/// Telegram-style slide-down notification banner for foreground messages.
class InAppNotificationBanner extends StatefulWidget {
  const InAppNotificationBanner({
    super.key,
    required this.senderName,
    required this.messagePreview,
    required this.onTap,
    this.avatarUrl,
  });

  final String senderName;
  final String messagePreview;
  final VoidCallback onTap;
  final String? avatarUrl;

  /// Shows the banner as an overlay for 4 seconds.
  static OverlayEntry show(
    BuildContext context, {
    required String senderName,
    required String messagePreview,
    required VoidCallback onTap,
    String? avatarUrl,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => InAppNotificationBanner(
        senderName: senderName,
        messagePreview: messagePreview,
        onTap: () {
          entry.remove();
          onTap();
        },
        avatarUrl: avatarUrl,
      ),
    );
    Overlay.of(context).insert(entry);

    // Auto-dismiss after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });

    return entry;
  }

  @override
  State<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(14),
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  AppAvatar(
                    name: widget.senderName,
                    imageUrl: widget.avatarUrl,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.senderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.messagePreview,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

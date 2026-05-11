import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/full_screen_image.dart';
import '../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final MessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isMine
        ? (isDark ? AppColors.bubbleOutgoingDark : AppColors.bubbleOutgoing)
        : (isDark ? AppColors.bubbleIncomingDark : AppColors.bubbleIncoming);

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 48 : 8,
        right: isMine ? 8 : 48,
        top: 2,
        bottom: 2,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: CustomPaint(
          painter: _BubbleTailPainter(isMine: isMine, color: bgColor),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMine ? 18 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMine ? 18 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sender name for incoming in groups
                  if (!isMine)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Text(
                        message.sender.username,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  _buildContent(context),
                  _buildFooter(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (message.isImage && message.hasMedia) {
      return _ImageContent(message: message);
    }
    if ((message.isFile || message.isAudio || message.isVideo) &&
        message.hasMedia) {
      return _FileContent(message: message);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 10, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Caption for media
          if (message.content.isNotEmpty && message.hasMedia)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          const Spacer(),
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 3),
            const Icon(
              Icons.done_all,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Bubble tail painter
// ---------------------------------------------------------------------------

class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter({required this.isMine, required this.color});
  final bool isMine;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (isMine) {
      // Tail on bottom-right
      path.moveTo(size.width, size.height - 4);
      path.lineTo(size.width + 6, size.height + 2);
      path.lineTo(size.width - 2, size.height);
      path.close();
    } else {
      // Tail on bottom-left
      path.moveTo(0, size.height - 4);
      path.lineTo(-6, size.height + 2);
      path.lineTo(2, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) =>
      old.isMine != isMine || old.color != color;
}

// ---------------------------------------------------------------------------
// Image content
// ---------------------------------------------------------------------------

class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.message});
  final MessageEntity message;

  @override
  Widget build(BuildContext context) {
    final heroTag = 'img_${message.id}';
    return GestureDetector(
      onTap: () => FullScreenImage.show(
        context,
        message.mediaUrl!,
        heroTag: heroTag,
      ),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: CachedNetworkImage(
            imageUrl: message.mediaUrl!,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              height: 220,
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 220,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File / Audio / Video content
// ---------------------------------------------------------------------------

class _FileContent extends StatelessWidget {
  const _FileContent({required this.message});
  final MessageEntity message;

  IconData get _icon {
    if (message.isAudio) return Icons.audiotrack_outlined;
    if (message.isVideo) return Icons.videocam_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color get _iconColor {
    if (message.isAudio) return const Color(0xFF9C27B0);
    if (message.isVideo) return const Color(0xFFE91E63);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (message.mediaUrl != null) OpenFilex.open(message.mediaUrl!);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _iconColor, size: 24),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.mediaFileName ?? 'File',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.formattedFileSize,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

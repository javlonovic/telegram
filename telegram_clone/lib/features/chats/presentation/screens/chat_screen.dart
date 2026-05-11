import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/presence_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/upload_progress_bubble.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/messages_provider.dart';
import '../providers/upload_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  Timer? _typingTimer;
  bool _isTyping = false;

  int get _chatId => int.parse(widget.chatId);

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (!_isTyping) {
      _isTyping = true;
      ref.read(messagesProvider(_chatId).notifier).sendTyping(true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      ref.read(messagesProvider(_chatId).notifier).sendTyping(false);
    });
  }

  void _sendText() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    ref.read(messagesProvider(_chatId).notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picked = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    await ref.read(uploadProvider(_chatId).notifier).uploadFile(File(picked.path));
    _scrollToBottom();
  }

  Future<void> _pickFile() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.any);
    if (result == null || result.files.single.path == null) return;
    await ref.read(uploadProvider(_chatId).notifier).uploadFile(File(result.files.single.path!));
    _scrollToBottom();
  }

  void _showAttachmentSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AttachOption(icon: Icons.photo_library_outlined, label: 'Gallery', color: const Color(0xFF2196F3), onTap: () => _pickImage(ImageSource.gallery)),
                  _AttachOption(icon: Icons.camera_alt_outlined, label: 'Camera', color: const Color(0xFF4CAF50), onTap: () => _pickImage(ImageSource.camera)),
                  _AttachOption(icon: Icons.insert_drive_file_outlined, label: 'File', color: const Color(0xFFFF9800), onTap: _pickFile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(_chatId));
    final uploadState = ref.watch(uploadProvider(_chatId));
    final currentUser = ref.watch(authNotifierProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final messages = messagesAsync.valueOrNull ?? [];
    final otherUser = messages.isNotEmpty
        ? messages.firstWhere(
            (m) => currentUser == null || m.sender.id != currentUser.id,
            orElse: () => messages.first,
          ).sender
        : null;

    final onlineStatus = ref.watch(onlineStatusProvider);
    final isOnline = otherUser != null ? (onlineStatus[otherUser.id] ?? false) : false;

    ref.listen(messagesProvider(_chatId), (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E1621) : const Color(0xFFEEF2F5),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        // Bug 1 fix: use context.pop() which works with GoRouter nested routes
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.chats);
            }
          },
        ),
        title: Row(
          children: [
            Stack(
              children: [
                AppAvatar(name: otherUser?.username ?? 'Chat', imageUrl: otherUser?.avatarUrl, size: 38),
                if (isOnline)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 11, height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.surfaceDark : AppColors.primary, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherUser?.username ?? 'Chat #${widget.chatId}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  _TypingOrOnlineStatus(chatId: _chatId, isOnline: isOnline),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty && !uploadState.isUploading) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 56, color: isDark ? Colors.white24 : Colors.black12),
                        const SizedBox(height: 12),
                        Text('No messages yet', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        const SizedBox(height: 4),
                        Text('Say hello 👋', style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemCount: messages.length + (uploadState.isUploading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (uploadState.isUploading && index == messages.length) {
                      return UploadProgressBubble(fileName: uploadState.fileName, progress: uploadState.progress);
                    }
                    final msg = messages[index];
                    final isMine = currentUser != null && msg.isMine(currentUser.id);
                    final showDate = index == 0 || !_sameDay(messages[index - 1].createdAt, msg.createdAt);
                    return Column(
                      children: [
                        if (showDate) _DateSeparator(date: msg.createdAt),
                        MessageBubble(message: msg, isMine: isMine),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          if (uploadState.error != null)
            MaterialBanner(
              backgroundColor: AppColors.error.withOpacity(0.1),
              content: Text(uploadState.error!, style: const TextStyle(color: AppColors.error)),
              actions: [
                TextButton(
                  onPressed: () => ref.read(uploadProvider(_chatId).notifier).clearError(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          // Bug 5 fix: mic button removed — only send button, only when there's text
          _MessageInput(controller: _messageController, onSend: _sendText, onAttach: _showAttachmentSheet, onChanged: _onTextChanged),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});
  final DateTime date;

  String _label() {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Text(_label(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _TypingOrOnlineStatus extends ConsumerWidget {
  const _TypingOrOnlineStatus({required this.chatId, required this.isOnline});
  final int chatId;
  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typingUsers = ref.watch(typingUsersProvider(chatId));
    if (typingUsers.isNotEmpty) {
      return Row(children: [_MiniTypingDots(), const SizedBox(width: 4), const Text('typing...', style: TextStyle(color: Colors.white70, fontSize: 12))]);
    }
    return Text(isOnline ? 'online' : 'last seen recently', style: const TextStyle(color: Colors.white70, fontSize: 12));
  }
}

class _MiniTypingDots extends StatefulWidget {
  @override
  State<_MiniTypingDots> createState() => _MiniTypingDotsState();
}

class _MiniTypingDotsState extends State<_MiniTypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        children: List.generate(3, (i) {
          final opacity = ((_ctrl.value - i / 3) % 1.0).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 4, height: 4,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70.withOpacity(0.3 + opacity * 0.7)),
          );
        }),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Bug 5 fix: no mic button — attach + text field + send (only when text exists)
class _MessageInput extends StatefulWidget {
  const _MessageInput({required this.controller, required this.onSend, required this.onAttach, this.onChanged});
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final ValueChanged<String>? onChanged;

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final has = widget.controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: isDark ? AppColors.surfaceDark : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              onPressed: widget.onAttach,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: widget.controller,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: widget.onChanged,
                  style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 15),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onSubmitted: (_) => widget.onSend(),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Only show send button when there's text — no mic button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _hasText
                  ? GestureDetector(
                      key: const ValueKey('send'),
                      onTap: widget.onSend,
                      child: Container(
                        width: 42, height: 42,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    )
                  : const SizedBox(key: ValueKey('empty'), width: 42, height: 42),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/in_app_notification_banner.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/chats_provider.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for foreground messages and show in-app banner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(foregroundMessageProvider, (_, next) {
        next.whenData((message) {
          final chatId =
              int.tryParse(message.data['chat_id']?.toString() ?? '');
          final senderName = message.notification?.title ?? 'New message';
          final body = message.notification?.body ?? '';

          // Increment badge
          if (chatId != null) {
            ref.read(unreadCountProvider.notifier).increment(chatId);
          }

          // Show banner
          InAppNotificationBanner.show(
            context,
            senderName: senderName,
            messagePreview: body,
            onTap: () {
              if (chatId != null) context.go('/chats/$chatId');
            },
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatsProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    final unreadCounts = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chats),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text('No chats yet. Start a conversation!'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(chatsProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final displayName = currentUser != null
                    ? chat.displayName(currentUser.id)
                    : 'Unknown';
                final avatarUrl = currentUser != null
                    ? chat.displayAvatar(currentUser.id)
                    : null;
                final unread = unreadCounts[chat.id] ?? 0;

                return ListTile(
                  leading: AppAvatar(
                    name: displayName,
                    imageUrl: avatarUrl,
                    size: 48,
                  ),
                  title: Text(
                    displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    chat.lastMessage?.content ?? 'No messages yet',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (chat.lastMessage != null)
                        Text(
                          _formatTime(chat.lastMessage!.createdAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      if (unread > 0) ...[
                        const SizedBox(height: 4),
                        _UnreadBadge(count: unread),
                      ],
                    ],
                  ),
                  onTap: () {
                    // Clear badge when opening chat
                    ref
                        .read(unreadCountProvider.notifier)
                        .clear(chat.id);
                    context.go('/chats/${chat.id}');
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatOptions(context),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  void _showNewChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Find User'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.search);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Contacts'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.contacts);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('New Group'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.newGroup);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/in_app_notification_banner.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/message_entity.dart';
import '../providers/chats_provider.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(foregroundMessageProvider, (_, next) {
        next.whenData((message) {
          final chatId =
              int.tryParse(message.data['chat_id']?.toString() ?? '');
          final senderName = message.notification?.title ?? 'New message';
          final body = message.notification?.body ?? '';
          if (chatId != null) {
            ref.read(unreadCountProvider.notifier).increment(chatId);
          }
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatsProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    final unreadCounts = ref.watch(unreadCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      drawer: _TelegramDrawer(currentUser: currentUser),
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: _searchQuery.isEmpty
            ? const Text(
                'Telegram',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              )
            : TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => _searchQuery = ' '),
            ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          final filtered = _searchQuery.trim().isEmpty
              ? chats
              : chats.where((c) {
                  final name = currentUser != null
                      ? c.displayName(currentUser.id).toLowerCase()
                      : '';
                  return name.contains(_searchQuery.trim());
                }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: isDark
                        ? Colors.white24
                        : Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.trim().isNotEmpty
                        ? 'No chats found'
                        : 'No chats yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (_searchQuery.trim().isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap the pencil icon to start a conversation',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.read(chatsProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final chat = filtered[index];
                final displayName = currentUser != null
                    ? chat.displayName(currentUser.id)
                    : 'Unknown';
                final avatarUrl = currentUser != null
                    ? chat.displayAvatar(currentUser.id)
                    : null;
                final unread = unreadCounts[chat.id] ?? 0;
                final lastMsg = chat.lastMessage;
                final isLastMine = currentUser != null &&
                    lastMsg?.sender.id == currentUser.id;

                return _ChatTile(
                  displayName: displayName,
                  avatarUrl: avatarUrl,
                  lastMessage: lastMsg?.content ?? '',
                  lastMessageType: lastMsg?.messageType,
                  time: lastMsg != null ? _formatTime(lastMsg.createdAt) : '',
                  unread: unread,
                  isLastMine: isLastMine,
                  onTap: () {
                    ref.read(unreadCountProvider.notifier).clear(chat.id);
                    context.go('/chats/${chat.id}');
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showNewChatOptions(context),
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }

  void _showNewChatOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _BottomSheetTile(
              icon: Icons.search,
              color: AppColors.primary,
              label: 'Find User',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.search);
              },
            ),
            _BottomSheetTile(
              icon: Icons.people_outline,
              color: const Color(0xFF4CAF50),
              label: 'Contacts',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.contacts);
              },
            ),
            _BottomSheetTile(
              icon: Icons.group_add_outlined,
              color: const Color(0xFF9C27B0),
              label: 'New Group',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.newGroup);
              },
            ),
            const SizedBox(height: 8),
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
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}/${dt.year % 100}';
  }
}

// ---------------------------------------------------------------------------
// Chat tile — Telegram-style
// ---------------------------------------------------------------------------

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.displayName,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageType,
    required this.time,
    required this.unread,
    required this.isLastMine,
    required this.onTap,
  });

  final String displayName;
  final String? avatarUrl;
  final String lastMessage;
  final MessageType? lastMessageType;
  final String time;
  final int unread;
  final bool isLastMine;
  final VoidCallback onTap;

  String get _preview {
    if (lastMessage.isEmpty) {
      if (lastMessageType == MessageType.image) return '📷 Photo';
      if (lastMessageType == MessageType.video) return '🎥 Video';
      if (lastMessageType == MessageType.audio) return '🎵 Audio';
      if (lastMessageType == MessageType.file) return '📎 File';
      return 'No messages yet';
    }
    return lastMessage;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AppAvatar(name: displayName, imageUrl: avatarUrl, size: 54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: unread > 0
                              ? AppColors.primary
                              : subColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (isLastMine)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.done_all,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          _preview,
                          style: TextStyle(fontSize: 14, color: subColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
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

// ---------------------------------------------------------------------------
// Bottom sheet tile
// ---------------------------------------------------------------------------

class _BottomSheetTile extends StatelessWidget {
  const _BottomSheetTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Telegram-style drawer
// ---------------------------------------------------------------------------

class _TelegramDrawer extends ConsumerWidget {
  const _TelegramDrawer({required this.currentUser});

  final dynamic currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Drawer(
      backgroundColor:
          isDark ? AppColors.backgroundDark : Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(
                  name: currentUser?.username,
                  imageUrl: currentUser?.avatarUrl,
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  currentUser?.username ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentUser?.phone ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.person_outline,
                  label: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.profile);
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  label: 'Contacts',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.contacts);
                  },
                ),
                _DrawerItem(
                  icon: Icons.search,
                  label: 'Find People',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.search);
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.settings);
                  },
                ),
                const Divider(height: 1),
                // Dark mode toggle inline
                SwitchListTile(
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Dark Mode'),
                  value: themeMode == ThemeMode.dark,
                  activeColor: AppColors.primary,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
              ],
            ),
          ),

          // Logout at bottom
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}

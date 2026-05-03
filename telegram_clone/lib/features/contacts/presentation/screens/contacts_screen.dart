import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/presence_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../chats/data/datasources/chat_remote_datasource.dart';
import '../providers/contacts_provider.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);
    final onlineStatus = ref.watch(onlineStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppRoutes.search),
          ),
        ],
      ),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No contacts yet.'),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Find people'),
                    onPressed: () => context.go(AppRoutes.search),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(contactsProvider.notifier).load(),
            child: ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final c = contacts[index];
                final isOnline =
                    onlineStatus[c.contact.id] ?? c.contact.isOnline;

                return ListTile(
                  leading: Stack(
                    children: [
                      AppAvatar(
                        name: c.displayName,
                        imageUrl: c.contact.avatarUrl,
                        size: AppSpacing.avatarMd,
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _OnlineDot(
                            bgColor: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                    ],
                  ),
                  title: Text(c.displayName),
                  subtitle: Text(
                    isOnline ? 'online' : c.contact.phone,
                    style: TextStyle(
                      color: isOnline
                          ? const Color(0xFF4DCD5E)
                          : null,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () async {
                      final ds = ChatRemoteDataSource();
                      final chat =
                          await ds.createPrivateChat(c.contact.id);
                      if (context.mounted) {
                        context.go('/chats/${chat.id}');
                      }
                    },
                  ),
                  onLongPress: () => _showRemoveDialog(context, ref, c.id, c.displayName),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showRemoveDialog(
      BuildContext context, WidgetRef ref, int contactId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Contact'),
        content: Text('Remove $name from your contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(contactsProvider.notifier).removeContact(contactId);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot({required this.bgColor});
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFF4DCD5E),
        shape: BoxShape.circle,
        border: Border.all(color: bgColor, width: 2),
      ),
    );
  }
}

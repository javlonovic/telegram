import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/presence_service.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../chats/data/datasources/chat_remote_datasource.dart';
import '../providers/contacts_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(userSearchProvider.notifier).search(value);
    });
  }

  Future<void> _startChat(UserEntity user) async {
    try {
      final ds = ChatRemoteDataSource();
      final chat = await ds.createPrivateChat(user.id);
      if (mounted) context.go('/chats/${chat.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(userSearchProvider);
    final onlineStatus = ref.watch(onlineStatusProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF232E3C)
            : const Color(0xFF2AABEE),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Search by username or phone...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _controller.clear();
                ref.read(userSearchProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: searchAsync.when(
        data: (users) {
          if (users.isEmpty && _controller.text.length >= 2) {
            return const Center(child: Text('No users found.'));
          }
          if (users.isEmpty) {
            return const Center(
              child: Text('Search for users by username or phone number.'),
            );
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isOnline = onlineStatus[user.id] ?? user.isOnline;
              return ListTile(
                leading: Stack(
                  children: [
                    AppAvatar(
                      name: user.username,
                      imageUrl: user.avatarUrl,
                      size: AppSpacing.avatarMd,
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: _OnlineDot(),
                      ),
                  ],
                ),
                title: Text(user.username),
                subtitle: Text(user.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => _startChat(user),
                ),
                onTap: () => _startChat(user),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFF4DCD5E),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
      ),
    );
  }
}

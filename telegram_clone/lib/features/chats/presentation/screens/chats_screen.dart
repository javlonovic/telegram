import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_avatar.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView.separated(
        itemCount: 10,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          return ListTile(
            leading: AppAvatar(name: 'User $index', size: 48),
            title: Text('User $index',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
            subtitle: Text('Last message preview...',
                style: Theme.of(context).textTheme.bodySmall),
            trailing: Text('12:0$index',
                style: Theme.of(context).textTheme.labelSmall),
            onTap: () => context.go('/chats/$index'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }
}

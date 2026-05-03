import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: AppAvatar(
                imageUrl: user?.avatarUrl,
                name: user?.username,
                size: AppSpacing.avatarXl,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              user?.username ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              user?.phone ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (user?.bio != null && user!.bio.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                user.bio,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text(AppStrings.settings),
              onTap: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}

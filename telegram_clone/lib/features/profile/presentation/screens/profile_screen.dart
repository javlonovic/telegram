import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Center(
              child: AppAvatar(name: 'John Doe', size: AppSpacing.avatarXl),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('John Doe', style: Theme.of(context).textTheme.headlineMedium),
            Text('+1 234 567 8900',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text(AppStrings.settings),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

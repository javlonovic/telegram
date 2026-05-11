import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5);
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _SectionLabel(label: 'Appearance', isDark: isDark),
          _SettingsCard(isDark: isDark, children: [
            SwitchListTile(
              secondary: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFF5856D6).withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.dark_mode_outlined, color: Color(0xFF5856D6), size: 20),
              ),
              title: const Text('Dark Mode', style: TextStyle(fontSize: 15)),
              subtitle: Text(isDark ? 'On' : 'Off', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              value: isDark,
              activeColor: AppColors.primary,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
            ),
          ]),
          const SizedBox(height: 12),
          _SectionLabel(label: 'Notifications', isDark: isDark),
          _SettingsCard(isDark: isDark, children: [
            _SettingsTile(icon: Icons.notifications_outlined, iconColor: const Color(0xFFFF9500), label: 'Notifications', subtitle: 'Enabled', onTap: () {}),
            const Divider(height: 1, indent: 52),
            _SettingsTile(icon: Icons.volume_up_outlined, iconColor: const Color(0xFF34C759), label: 'Sounds', subtitle: 'Default', onTap: () {}),
          ]),
          const SizedBox(height: 12),
          _SectionLabel(label: 'Privacy & Security', isDark: isDark),
          _SettingsCard(isDark: isDark, children: [
            _SettingsTile(icon: Icons.lock_outline, iconColor: const Color(0xFF007AFF), label: 'Privacy', subtitle: 'Manage your privacy settings', onTap: () {}),
            const Divider(height: 1, indent: 52),
            _SettingsTile(icon: Icons.security_outlined, iconColor: const Color(0xFFFF3B30), label: 'Security', subtitle: 'Two-step verification', onTap: () {}),
          ]),
          const SizedBox(height: 12),
          _SectionLabel(label: 'Data & Storage', isDark: isDark),
          _SettingsCard(isDark: isDark, children: [
            _SettingsTile(icon: Icons.storage_outlined, iconColor: const Color(0xFF5AC8FA), label: 'Storage Usage', subtitle: 'Manage cache and downloads', onTap: () {}),
          ]),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout, color: Colors.red, size: 20),
              ),
              title: const Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 15)),
              onTap: () => ref.read(authNotifierProvider.notifier).logout(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.children});
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.iconColor, required this.label, this.subtitle, required this.onTap});
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)) : null,
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}

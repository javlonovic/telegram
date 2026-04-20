import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/app_providers.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TelegramApp(),
    ),
  );
}

class TelegramApp extends ConsumerWidget {
  const TelegramApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Telegram Clone',
      debugShowCheckedModeBanner: false,
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

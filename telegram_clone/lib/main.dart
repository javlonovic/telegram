import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase/firebase_options.dart';
import 'core/providers/app_providers.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: TelegramApp(),
    ),
  );
}

class TelegramApp extends ConsumerStatefulWidget {
  const TelegramApp({super.key});

  @override
  ConsumerState<TelegramApp> createState() => _TelegramAppState();
}

class _TelegramAppState extends ConsumerState<TelegramApp> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    final notificationService = NotificationService.instance;

    // Navigate to chat when user taps a notification
    notificationService.onNotificationTap = (chatId) {
      final router = ref.read(routerProvider);
      router.go('/chats/$chatId');
    };

    await notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
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

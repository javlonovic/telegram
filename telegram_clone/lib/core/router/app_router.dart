import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/chats/presentation/screens/chats_screen.dart';
import '../../features/chats/presentation/screens/chat_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';

/// Centralized router configuration.
/// Route guards will be added here in Phase 2 when auth state is implemented.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.chats,
        name: 'chats',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChatsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: ChatScreen(chatId: state.pathParameters['chatId']!),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
}

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
    child: child,
  );
}

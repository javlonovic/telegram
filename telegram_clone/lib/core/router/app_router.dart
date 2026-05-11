import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/chats/presentation/screens/chats_screen.dart';
import '../../features/chats/presentation/screens/chat_screen.dart';
import '../../features/chats/presentation/screens/new_group_screen.dart';
import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/contacts/presentation/screens/search_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

const _publicRoutes = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.register,
};

GoRouter buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final loc = state.matchedLocation;

      // Still loading — stay on splash
      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return AppRoutes.splash;
      }

      final isPublic = _publicRoutes.contains(loc);

      // Not authenticated trying to access protected route
      if ((authState.status == AuthStatus.unauthenticated ||
              authState.status == AuthStatus.error) &&
          !isPublic) {
        return AppRoutes.login;
      }

      // Error on splash — go to login
      if (authState.status == AuthStatus.error && loc == AppRoutes.splash) {
        return AppRoutes.login;
      }

      // Authenticated trying to access auth/onboarding screens
      if (authState.isAuthenticated && isPublic && loc != AppRoutes.splash) {
        return AppRoutes.chats;
      }

      return null;
    },
    routes: [
      // ── Public ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: _fadeTransition,
        ),
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

      // ── Authenticated — chats is the root, everything else is a child ──
      GoRoute(
        path: AppRoutes.chats,
        name: 'chats',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChatsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
        routes: [
          // Static named routes MUST come before the :chatId wildcard
          // /chats/profile
          GoRoute(
            path: 'profile',
            name: 'profile',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: _slideTransition,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                pageBuilder: (_, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const EditProfileScreen(),
                  transitionsBuilder: _slideTransition,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: 'contacts',
            name: 'contacts',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ContactsScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: 'search',
            name: 'search',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SearchScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: 'new-group',
            name: 'new-group',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const NewGroupScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          // :chatId wildcard LAST — only matches numeric IDs
          GoRoute(
            path: ':chatId',
            name: 'chat',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: ChatScreen(chatId: state.pathParameters['chatId']!),
              transitionsBuilder: _slideTransition,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
}

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, __) => notifyListeners());
  }
}

Widget _fadeTransition(_, animation, __, child) =>
    FadeTransition(opacity: animation, child: child);

Widget _slideTransition(_, animation, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );

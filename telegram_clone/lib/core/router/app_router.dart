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

// Routes that require auth but should never be redirected away from
const _protectedRoutes = {
  AppRoutes.chats,
  AppRoutes.profile,
  AppRoutes.editProfile,
  AppRoutes.settings,
  AppRoutes.contacts,
  AppRoutes.search,
  AppRoutes.newGroup,
};

GoRouter buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final loc = state.matchedLocation;

      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return AppRoutes.splash;
      }

      final isPublic = _publicRoutes.contains(loc);

      if ((authState.status == AuthStatus.unauthenticated ||
              authState.status == AuthStatus.error) &&
          !isPublic) {
        return AppRoutes.login;
      }

      if (authState.status == AuthStatus.error && loc == AppRoutes.splash) {
        return AppRoutes.login;
      }

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

      // ── Authenticated — all flat, use context.push() for back stack ──
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
        path: AppRoutes.editProfile,
        name: 'edit-profile',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
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
      GoRoute(
        path: AppRoutes.contacts,
        name: 'contacts',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ContactsScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SearchScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.newGroup,
        name: 'new-group',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NewGroupScreen(),
          transitionsBuilder: _slideTransition,
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Router Provider
// ---------------------------------------------------------------------------

/// Provides the GoRouter instance. Kept as a plain Provider since GoRouter
/// manages its own lifecycle.
final routerProvider = Provider<GoRouter>((ref) {
  return buildRouter();
});

// ---------------------------------------------------------------------------
// Theme Providers
// ---------------------------------------------------------------------------

final lightThemeProvider = Provider<ThemeData>((ref) => AppTheme.light);
final darkThemeProvider = Provider<ThemeData>((ref) => AppTheme.dark);

/// Manages the current ThemeMode with a toggle method.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

// ---------------------------------------------------------------------------
// Auth Provider (stub — logic added in Phase 2)
// ---------------------------------------------------------------------------

enum AuthStatus { unknown, authenticated, unauthenticated }

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthStatus> {
  AuthNotifier() : super(AuthStatus.unknown);

  // TODO Phase 2: implement login / logout / token refresh
  void setAuthenticated() => state = AuthStatus.authenticated;
  void setUnauthenticated() => state = AuthStatus.unauthenticated;
}

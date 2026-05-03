import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/presence_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepositoryImpl(),
);

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuthStatus();
  }

  final AuthRepository _repository;

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isAuth = await _repository.isAuthenticated();
      if (isAuth) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
          PresenceService.instance.connect().catchError((_) {});
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String phone, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.login(phone: phone, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      // Don't await — these should not block navigation
      NotificationService.instance.initialize().catchError((_) {});
      PresenceService.instance.connect().catchError((_) {});
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> register({
    required String username,
    required String phone,
    required String password,
    required String password2,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.register(
        username: username,
        phone: phone,
        password: password,
        password2: password2,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      // Don't await — these should not block navigation
      NotificationService.instance.initialize().catchError((_) {});
      PresenceService.instance.connect().catchError((_) {});
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> updateProfile({
    String? username,
    String? bio,
    String? avatarPath,
  }) async {
    try {
      final user = await _repository.updateProfile(
        username: username,
        bio: bio,
        avatarPath: avatarPath,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {    await NotificationService.instance.clearToken();
    await PresenceService.instance.disconnect();
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

import '../entities/user_entity.dart';

/// Contract — data layer must implement this.
abstract class AuthRepository {
  Future<UserEntity> login({required String phone, required String password});

  Future<UserEntity> register({
    required String username,
    required String phone,
    required String password,
    required String password2,
  });

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();

  Future<bool> isAuthenticated();

  Future<UserEntity> updateProfile({
    String? username,
    String? bio,
    String? avatarPath,
  });
}

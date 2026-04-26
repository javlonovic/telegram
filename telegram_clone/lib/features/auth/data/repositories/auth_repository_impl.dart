import 'package:dio/dio.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl() : _dataSource = AuthRemoteDataSource();

  final AuthRemoteDataSource _dataSource;

  @override
  Future<UserEntity> login({
    required String phone,
    required String password,
  }) async {
    try {
      final model = await _dataSource.login(phone: phone, password: password);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<UserEntity> register({
    required String username,
    required String phone,
    required String password,
    required String password2,
  }) async {
    try {
      final model = await _dataSource.register(
        username: username,
        phone: phone,
        password: password,
        password2: password2,
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final model = await _dataSource.getMe();
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() => TokenStorage.instance.hasTokens();

  /// Maps Dio errors to readable messages.
  Exception _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'] ?? data.values.first;
      if (detail is List) return Exception(detail.first.toString());
      return Exception(detail.toString());
    }
    return Exception('Network error. Please try again.');
  }
}

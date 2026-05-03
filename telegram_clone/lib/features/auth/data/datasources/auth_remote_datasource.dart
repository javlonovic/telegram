import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_storage.dart';
import '../models/user_model.dart';

/// Handles all raw HTTP calls for auth.
class AuthRemoteDataSource {
  AuthRemoteDataSource() : _dio = DioClient.instance.dio;

  final Dio _dio;

  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'phone': phone, 'password': password},
    );
    await _saveTokens(response.data);
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String username,
    required String phone,
    required String password,
    required String password2,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'username': username,
        'phone': phone,
        'password': password,
        'password2': password2,
      },
    );
    await _saveTokens(response.data);
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final refresh = await TokenStorage.instance.getRefreshToken();
    try {
      await _dio.post(ApiConstants.logout, data: {'refresh': refresh});
    } catch (_) {
      // Best-effort — always clear local tokens
    }
    await TokenStorage.instance.clearTokens();
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    String? username,
    String? bio,
    String? avatarPath,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (avatarPath != null) {
      data['avatar'] = await MultipartFile.fromFile(avatarPath);
    }
    final response = await _dio.patch(
      ApiConstants.me,
      data: FormData.fromMap(data),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await TokenStorage.instance.saveTokens(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
    );
  }
}

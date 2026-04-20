import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles secure persistence of JWT tokens.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: access),
      _storage.write(key: _refreshKey, value: refresh),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

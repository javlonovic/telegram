import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'token_storage.dart';

/// Singleton Dio client with JWT auth interceptor and token refresh logic.
class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_AuthInterceptor(dio));

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio);

  final Dio _dio;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request with new token
          final token = await TokenStorage.instance.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        await TokenStorage.instance.clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refresh = await TokenStorage.instance.getRefreshToken();
    if (refresh == null) return false;

    final response = await _dio.post(
      ApiConstants.tokenRefresh,
      data: {'refresh': refresh},
    );

    if (response.statusCode == 200) {
      await TokenStorage.instance.saveTokens(
        access: response.data['access'],
        refresh: response.data['refresh'] ?? refresh,
      );
      return true;
    }
    return false;
  }
}

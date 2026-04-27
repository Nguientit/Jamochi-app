import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class DioClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  // Callback để gọi logout khi token hết hạn (được gắn từ AuthProvider)
  Function()? onUnauthorized;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },

      onResponse: (response, handler) {
        return handler.next(response);
      },

      onError: (DioException e, handler) async {
        // Token hết hạn → tự động logout
        if (e.response?.statusCode == 401) {
          await _storage.deleteAll();
          onUnauthorized?.call();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'jwt_token');
  }

  Future<void> clearToken() async {
    await _storage.deleteAll();
  }
}
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../network/dio_client.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient();

  // ── Đăng nhập ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dioClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return res.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi kết nối đến máy chủ';
    }
  }

  // ── Đăng ký ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final res = await _dioClient.dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
        },
      );
      return res.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi kết nối đến máy chủ';
    }
  }

  // ── Lấy thông tin user hiện tại ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _dioClient.dio.get(ApiConstants.me);
      return res.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi kết nối đến máy chủ';
    }
  }

  // ── Tạo mã mời ghép đôi ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> generateInvite() async {
    try {
      final res = await _dioClient.dio.post(ApiConstants.generateInvite);
      return res.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi kết nối đến máy chủ';
    }
  }

  // ── Nhập mã mời để ghép đôi ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> acceptInvite(String inviteCode) async {
    try {
      final res = await _dioClient.dio.post(
        ApiConstants.acceptInvite,
        data: {'invite_code': inviteCode},
      );
      return res.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi kết nối đến máy chủ';
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      // Nhớ sửa lại đường dẫn '/auth/fcm-token' cho khớp với cấu hình API của bạn nhé
      await _dioClient.dio.patch('/auth/fcm-token', data: {'fcm_token': token});
      print('✅ Đã gửi FCM Token lên Server thành công!');
    } catch (e) {
      print('🚨 Lỗi gửi FCM Token lên Server: $e');
    }
  }

  // ── Lưu token ────────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) => _dioClient.saveToken(token);
  Future<void> clearToken() => _dioClient.clearToken();
  Future<String?> getToken() => _dioClient.getToken();
}

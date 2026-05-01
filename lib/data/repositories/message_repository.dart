// data/repositories/message_repository.dart
// 📁 JAMOCHI_APP/lib/data/repositories/message_repository.dart

import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../network/dio_client.dart';

class MessageRepository {
  final DioClient _dioClient;
  MessageRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  // ── Lấy lịch sử tin nhắn ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getMessages({String? before, int limit = 500}) async {
    try {
      final res = await _dioClient.dio.get(
        ApiConstants.messages,
        queryParameters: {
          if (before != null) 'before': before,
          'limit': limit,
        },
      );
      final data = (res.data as Map<String, dynamic>)['data'];
      if (data is! List) return [];
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {
      // Lỗi fetch messages
      throw _parseError(e, 'Không thể tải tin nhắn');
    }
  }

  // ── Gửi tin nhắn văn bản ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> sendMessage(String content, {String? replyToId}) async {
    try {
      final res = await _dioClient.dio.post(
        ApiConstants.messages,
        data: {
          'type':        'text',
          'content':     content,
          if (replyToId != null) 'reply_to_id': replyToId,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Lỗi send message
      throw _parseError(e, 'Gửi tin nhắn thất bại');
    }
  }

  // ── Gửi ảnh ──────────────────────────────────────────────────────────────
  // Upload file lên server, server lưu vào Cloudinary/S3 rồi trả về URL
  Future<Map<String, dynamic>> sendImage(XFile imageFile, {String? caption}) async {
    try {
      final fileName  = imageFile.name; // XFile có sẵn tên
      final bytes     = await imageFile.readAsBytes(); // 🎯 Đọc file ra dạng byte (Hỗ trợ mọi nền tảng)

      final formData  = FormData.fromMap({
        'type':    'image',
        'content': caption ?? '',
        // 🎯 SỬA: Dùng fromBytes thay vì fromFile
        'file':    MultipartFile.fromBytes(bytes, filename: fileName), 
      });

      final res = await _dioClient.dio.post(
        ApiConstants.messages,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Lỗi send image
      throw _parseError(e, 'Gửi ảnh thất bại');
    }
  }

  // ── React tin nhắn ────────────────────────────────────────────────────────
  Future<void> reactMessage(String messageId, String? emoji) async {
    try {
      await _dioClient.dio.patch(
        ApiConstants.messageReact(messageId),
        data: {'emoji': emoji}, // null = bỏ react
      );
    } on DioException catch (e) {
      throw _parseError(e, 'React thất bại');
    }
  }

  // ── Xóa tin nhắn ─────────────────────────────────────────────────────────
  Future<void> deleteMessage(String messageId) async {
    try {
      await _dioClient.dio.delete(ApiConstants.messageDelete(messageId));
    } on DioException catch (e) {
      throw _parseError(e, 'Xóa tin nhắn thất bại');
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  String _parseError(DioException e, String fallback) {
    final body = e.response?.data;
    if (body is Map) return body['message']?.toString() ?? fallback;
    return fallback;
  }
}
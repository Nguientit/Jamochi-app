// data/repositories/mood_repository.dart
// 📁 JAMOCHI_APP/lib/data/repositories/mood_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../network/dio_client.dart';

class MoodRepository {
  final DioClient _dioClient = DioClient();

  // ── GET /api/mood/forecast/today ─────────────────────────────────────────
  Future<Map<String, dynamic>> getLatestMood() async {
    try {
      // 🛡️ FIX: Dùng đúng endpoint từ ApiConstants
      final res = await _dioClient.dio.get(ApiConstants.moodToday);

      if (res.data == null) {
        return {'success': false, 'data': null};
      }

      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // In log chi tiết để debug
      // Lỗi fetch mood
      final msg = e.response?.data?['message'] ?? 'Không thể lấy dữ liệu tâm trạng';
      throw msg as String;
    } catch (e) {
      throw 'Lỗi hệ thống getLatestMood: $e';
    }
  }

  // ── POST /api/mood/forecast ──────────────────────────────────────────────
  Future<Map<String, dynamic>> updateMood(
    String moodId, {
    int moodScore = 5,
    List<String> moodEmojis = const [],
    List<String> needs = const [],
    String? needsNote,
  }) async {
    try {
      final res = await _dioClient.dio.post(
        ApiConstants.moodForecast,  // POST endpoint
        data: {
          'mood':        moodId,
          'mood_score':  moodScore,
          'mood_emojis': moodEmojis,
          'needs':       needs,
          'needs_note':  needsNote,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Lỗi update mood
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi cập nhật mood';
      throw msg as String;
    } catch (e) {
      throw 'Lỗi hệ thống updateMood: $e';
    }
  }

  // ── GET /api/mood/forecast/history ───────────────────────────────────────
  Future<List<dynamic>> getMoodHistory({int days = 30}) async {
    try {
      final res = await _dioClient.dio.get(
        ApiConstants.moodHistory,
        queryParameters: {'days': days},
      );
      return (res.data['data'] as List?) ?? [];
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Không thể lấy lịch sử';
      throw msg as String;
    }
  }
}
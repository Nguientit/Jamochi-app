import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../network/dio_client.dart';

class MessageRepository {
  final DioClient _dioClient;

  MessageRepository({DioClient? dioClient}) 
    : _dioClient = dioClient ?? DioClient();

  // Lấy lịch sử tin nhắn
  Future<List<Map<String, dynamic>>> getMessages() async {
    try {
      final res = await _dioClient.dio.get(ApiConstants.messages + "/history");
      
      if (res.data == null) {
        print('[MessageRepo] ⚠️ API trả về null');
        return [];
      }
      
      final dataField = (res.data as Map<String, dynamic>)['data'];
      if (dataField is! List) {
        print('[MessageRepo] ⚠️ data field không phải List');
        return [];
      }
      
      return List<Map<String, dynamic>>.from(dataField as List);
    } on DioException catch (e) {
      print('[MessageRepo] ❌ Lỗi getMessages (Dio): ${e.message}');
      print('[MessageRepo] Status: ${e.response?.statusCode}');
      print('[MessageRepo] Body: ${e.response?.data}');
      throw 'Không thể tải tin nhắn: ${e.response?.data['message'] ?? e.message}';
    } catch (e) {
      print('[MessageRepo] ❌ Lỗi getMessages: $e');
      throw 'Lỗi tải tin nhắn: $e';
    }
  }

  // Gửi tin nhắn
  Future<Map<String, dynamic>> sendMessage(String content) async {
    try {
      print('[MessageRepo] 📤 Gửi POST đến: ${ApiConstants.messages}/send');
      print('[MessageRepo] 📝 Body: {type: text, content: $content}');
      
      final res = await _dioClient.dio.post(
        ApiConstants.messages + "/send",
        data: {
          'type': 'text',
          'content': content,
        }
      );
      
      print('[MessageRepo] ✅ Gửi thành công');
      print('[MessageRepo] 📩 Response: ${res.data}');
      
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('[MessageRepo] ❌ Lỗi sendMessage (Dio): ${e.message}');
      print('[MessageRepo] Status: ${e.response?.statusCode}');
      print('[MessageRepo] Body: ${e.response?.data}');
      
      final errorMsg = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Lỗi gửi tin nhắn'
          : e.message;
      
      throw 'Gửi tin nhắn thất bại: $errorMsg';
    } catch (e) {
      print('[MessageRepo] ❌ Lỗi sendMessage: $e');
      throw 'Lỗi gửi tin nhắn: $e';
    }
  }
}

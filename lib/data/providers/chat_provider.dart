import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../network/dio_client.dart';
import '../network/socket_client.dart';
import '../repositories/message_repository.dart';
import '../../models/message.dart';
import 'auth_provider.dart';

// ── MessageRepository Provider ──
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

// ── State ──
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool hasUnreadMessages; // 🎯 Track unread messages

  ChatState({
    this.messages = const [], 
    this.isLoading = false,
    this.hasUnreadMessages = false,
  });
  
  ChatState copyWith({
    List<ChatMessage>? messages, 
    bool? isLoading,
    bool? hasUnreadMessages,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }
}

// ── Notifier ──
// ── Notifier ──
class ChatNotifier extends StateNotifier<ChatState> {
  final MessageRepository _repo;
  final SocketClient _socket;
  final String myUserId; // 🎯 Thêm biến này để lưu ID của mình

  // 🎯 Thêm myUserId vào constructor
  ChatNotifier(this._repo, this._socket, this.myUserId) : super(ChatState()) {
    _listenToSockets();
    loadHistory();
  }

  void _listenToSockets() {
    _socket.onReceiveMessage((data) {
      try {
        if (data == null || data is! Map<String, dynamic>) return;

        final newMessage = ChatMessage.fromJson(data);

        // 🛡️ FIX NHÂN ĐÔI: Bỏ qua tin nhắn do chính mình gửi qua Socket
        if (newMessage.senderId == myUserId) return;

        if (!state.messages.any((m) => m.id == newMessage.id)) {
          state = state.copyWith(
            messages: [newMessage, ...state.messages],
            hasUnreadMessages: true, // 🎯 Set badge khi có message từ partner
          );
          print('[Chat] ✅ Received message: ${newMessage.id}');
        }
      } catch (e) {
        print('[Chat] ❌ Lỗi parse message: $e');
      }
    });
  }
  
  // 🎯 Hàm để xóa unread badge khi mở chat screen
  void clearUnreadBadge() {
    state = state.copyWith(hasUnreadMessages: false);
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final messageData = await _repo.getMessages();
      final loadedMsgs = <ChatMessage>[];
      for (final item in messageData) {
        try {
          loadedMsgs.add(ChatMessage.fromJson(item));
        } catch (_) {}
      }
      final reversed = loadedMsgs.reversed.toList();
      state = state.copyWith(
        messages: reversed,
        isLoading: false,
        // Giữ lại hasUnreadMessages nếu đã được set
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // 🎯 Gửi tin nhắn
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final trimmedText = text.trim();
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // 1. Tạo tin nhắn tạm với ĐÚNG senderId của người gửi
      final tempMessage = ChatMessage(
        id: tempId,
        senderId: myUserId, // <-- Gắn ID của bạn vào đây
        content: trimmedText,
        type: 'text',
        createdAt: DateTime.now(),
      );

      // 2. Hiện ngay lên màn hình bên PHẢI
      state = state.copyWith(messages: [tempMessage, ...state.messages]);

      // 3. Gửi lên API Backend
      final res = await _repo.sendMessage(trimmedText);

      // 4. Lấy ID thật từ Server ghi đè lên ID tạm (để Socket dội về không bị nhân đôi)
      if (res['data'] != null) {
        final realMessage = ChatMessage.fromJson(res['data']);
        state = state.copyWith(
          messages: state.messages
              .map((m) => m.id == tempId ? realMessage : m)
              .toList(),
        );
      }
    } catch (e) {
      // Nếu lỗi, xóa tin nhắn tạm đi
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempId).toList(),
      );
      rethrow;
    }
  }
}

// ── Provider ──
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  final socket = ref.read(socketClientProvider);

  final user = ref.read(authProvider).user;
  return ChatNotifier(repo, socket, user?.id ?? '');
});

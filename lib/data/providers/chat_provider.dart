// data/providers/chat_provider.dart
// 📁 JAMOCHI_APP/lib/data/providers/chat_provider.dart

import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/message.dart';
import '../network/socket_client.dart';
import '../repositories/message_repository.dart';
import 'auth_provider.dart';

// ── Config Gemini ─────────────────────────────────────────────────────────────
// Thêm GEMINI_API_KEY vào .env của Flutter (hoặc hardcode khi test)
const _geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'AIzaSyBWWAO-gGSaG2FcG9NNusZb2FUjnj1O46c',
);

// ── State ─────────────────────────────────────────────────────────────────────
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool hasUnread;
  final bool isPartnerTyping;
  final PartnerStatus partnerStatus;
  final ChatMessage? replyingTo;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.hasUnread = false,
    this.isPartnerTyping = false,
    this.partnerStatus = const PartnerStatus(isOnline: false),
    this.replyingTo,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? hasUnread,
    bool? isPartnerTyping,
    PartnerStatus? partnerStatus,
    ChatMessage? replyingTo,
    bool clearReply = false,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      hasUnread: hasUnread ?? this.hasUnread,
      isPartnerTyping: isPartnerTyping ?? this.isPartnerTyping,
      partnerStatus: partnerStatus ?? this.partnerStatus,
      replyingTo: clearReply ? null : (replyingTo ?? this.replyingTo),
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class ChatNotifier extends StateNotifier<ChatState> {
  final MessageRepository _repo;
  final SocketClient _socket;
  final String myUserId;
  final String partnerId;

  // Gemini model — khởi tạo lazy để không crash nếu key chưa có
  GenerativeModel? _gemini;

  ChatNotifier(this._repo, this._socket, this.myUserId, this.partnerId)
    : super(const ChatState()) {
    _initGemini();
    _listenToSockets();
    loadHistory();
  }

  void _initGemini() {
    try {
      if (_geminiApiKey == 'AIzaSyBWWAO-gGSaG2FcG9NNusZb2FUjnj1O46c') return;
      _gemini = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        systemInstruction: Content.system(
          'Bạn là một chatbot an ủi dễ thương tên "Mochi AI", '
          'dành cho một cô gái đang chờ bạn trai online. '
          'Hãy nói chuyện bằng tiếng Việt, thân mật, dùng từ "bạn" và "mình", '
          'hài hước nhẹ nhàng, dùng emoji vừa phải. '
          'Không được nhắc tới việc bạn là AI. '
          'Mục tiêu: làm cô ấy vui lên và không còn buồn vì chờ đợi.',
        ),
      );
    } catch (e) {
      // Lỗi init Gemini
    }
  }

  // ── Socket listeners ────────────────────────────────────────────────────────
  void _listenToSockets() {
    // Nhận tin nhắn từ partner
    _socket.onReceiveMessage((data) {
      try {
        final msg = ChatMessage.fromJson(data);

        if (msg.senderId == myUserId) return; // tránh nhân đôi
        if (state.messages.any((m) => m.id == msg.id)) return;

        // 🎯 CHUYỂN ĐỔI SANG MÚI GIỜ ĐỊA PHƯƠNG TRƯỚC KHI LƯU VÀO STATE
        final localMsg = msg.copyWith(createdAt: msg.createdAt.toLocal());

        state = state.copyWith(
          messages: [localMsg, ...state.messages],
          hasUnread: true,
        );
      } catch (e) {
        // Lỗi parse message
      }
    });

    // Typing indicator
    _socket.onPartnerTyping(
      () => state = state.copyWith(isPartnerTyping: true),
    );
    _socket.onPartnerStoppedTyping(
      () => state = state.copyWith(isPartnerTyping: false),
    );

    // Reaction realtime
    _socket.onMessageReacted((data) {
      final msgId = data['message_id']?.toString() ?? '';
      final emoji = data['emoji']?.toString();
      _updateReactionLocally(msgId, emoji);
    });

    // Online / offline status
    _socket.onPartnerOnline((userId) {
      if (userId == partnerId) {
        state = state.copyWith(
          partnerStatus: const PartnerStatus(isOnline: true),
          isPartnerTyping: false,
        );
      }
    });

    _socket.onPartnerOffline((userId, lastSeen) {
      if (userId == partnerId) {
        state = state.copyWith(
          partnerStatus: PartnerStatus(isOnline: false, lastSeen: lastSeen),
          isPartnerTyping: false,
        );
        // 🤖 Tự động gọi Gemini an ủi khi partner offline
        _triggerGeminiComfort();
      }
    });
  }

  // ── Load lịch sử ────────────────────────────────────────────────────────────
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repo.getMessages();
      final msgs = data
          .map((d) {
            try {
              // Parse data từ DB
              final msg = ChatMessage.fromJson(d);

              // 🎯 CHUYỂN ĐỔI SANG MÚI GIỜ ĐỊA PHƯƠNG (LOCAL TIME)
              return msg.copyWith(createdAt: msg.createdAt.toLocal());
            } catch (_) {
              return null;
            }
          })
          .whereType<ChatMessage>()
          .toList();

      // API trả về mới nhất cuối — đảo ngược để newest ở index 0 (reverse ListView)
      state = state.copyWith(
        messages: msgs.reversed.toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── Gửi text ────────────────────────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final trimmed = text.trim();
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final replyTo = state.replyingTo;

    final tempMsg = ChatMessage(
      id: tempId,
      senderId: myUserId,
      content: trimmed,
      type: 'text',
      replyToId: replyTo?.id,
      replyContent: replyTo?.content,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [tempMsg, ...state.messages],
      isSending: true,
      clearReply: true,
    );

    try {
      final res = await _repo.sendMessage(trimmed, replyToId: replyTo?.id); //
      if (res['data'] != null) {
        final realMsg = ChatMessage.fromJson(res['data']);

        final localRealMsg = realMsg.copyWith(
          createdAt: realMsg.createdAt.toLocal(),
        );

        state = state.copyWith(
          messages: state.messages
              .map((m) => m.id == tempId ? localRealMsg : m)
              .toList(),
          isSending: false,
        );
      }
    } catch (e) {
      // Xóa tin tạm nếu lỗi
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempId).toList(),
        isSending: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // ── Gửi ảnh ─────────────────────────────────────────────────────────────────
  Future<void> sendImage(XFile imageFile) async {
    final tempId = 'temp_img_${DateTime.now().millisecondsSinceEpoch}';

    // Hiện preview ngay (dùng path local)
    final tempMsg = ChatMessage(
      id: tempId,
      senderId: myUserId,
      type: 'image',
      mediaUrl: imageFile.path,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [tempMsg, ...state.messages],
      isSending: true,
    );

    try {
      final res = await _repo.sendImage(imageFile);
      if (res['data'] != null) {
        final realMsg = ChatMessage.fromJson(res['data']);

        final localRealMsg = realMsg.copyWith(
          createdAt: realMsg.createdAt.toLocal(),
        );

        state = state.copyWith(
          messages: state.messages
              .map((m) => m.id == tempId ? localRealMsg : m)
              .toList(),
          isSending: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempId).toList(),
        isSending: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // ── React tin nhắn ───────────────────────────────────────────────────────────
  Future<void> reactToMessage(String messageId, String? emoji) async {
    // Cập nhật UI ngay (optimistic)
    _updateReactionLocally(messageId, emoji);

    try {
      await _repo.reactMessage(messageId, emoji);
    } catch (e) {
      // Rollback nếu API lỗi
      _updateReactionLocally(messageId, null);
      state = state.copyWith(errorMessage: 'React thất bại: $e');
    }
  }

  void _updateReactionLocally(String messageId, String? emoji) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == messageId) return m.copyWithReaction(emoji);
        return m;
      }).toList(),
    );
  }

  // ── Reply ────────────────────────────────────────────────────────────────────
  void setReplyTo(ChatMessage? msg) => state = state.copyWith(replyingTo: msg);
  void cancelReply() => state = state.copyWith(clearReply: true);

  // ── Gemini: tự động an ủi khi partner offline ─────────────────────────────
  Future<void> _triggerGeminiComfort() async {
    if (_gemini == null) return;

    // Chỉ trigger nếu cô ấy là người đang dùng (không phải bạn trai)
    // Logic: nếu myUserId không phải sender của đa số tin → cô ấy đang chờ
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Chờ 3 giây trước khi hiện

    try {
      final response = await _gemini!.generateContent([
        Content.text(
          'Bạn trai của tôi vừa offline. Hãy an ủi tôi một câu ngắn gọn, dễ thương, '
          'và gợi ý tôi làm gì trong lúc chờ. Đừng quá 2 câu.',
        ),
      ]);

      final text = response.text?.trim();
      if (text == null || text.isEmpty) return;

      // Thêm tin nhắn từ "Mochi AI" vào chat
      final aiMsg = ChatMessage(
        id: 'gemini_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'mochi_ai', // senderId đặc biệt để nhận dạng
        content: text,
        type: 'text',
        createdAt: DateTime.now(),
      );

      state = state.copyWith(messages: [aiMsg, ...state.messages]);
    } catch (e) {
      // Lỗi Gemini comfort
    }
  }

  // ── Hỏi Gemini thủ công ──────────────────────────────────────────────────
  Future<void> askGemini(String question) async {
    if (_gemini == null) {
      state = state.copyWith(errorMessage: 'Mochi AI chưa được cấu hình 🤖');
      return;
    }

    // Thêm câu hỏi của user
    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      senderId: myUserId,
      content: question,
      type: 'text',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [userMsg, ...state.messages],
      isSending: true,
    );

    try {
      final response = await _gemini!.generateContent([Content.text(question)]);
      final text =
          response.text?.trim() ?? 'Mình không biết trả lời câu này 😅';

      final aiMsg = ChatMessage(
        id: 'gemini_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'mochi_ai',
        content: text,
        type: 'text',
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [aiMsg, ...state.messages],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Mochi AI lỗi: $e',
      );
    }
  }

  // ── Xóa tin nhắn ────────────────────────────────────────────────────────────
  Future<void> deleteMessage(String messageId) async {
    // 1. Lưu lại danh sách cũ phòng trường hợp gọi API bị lỗi (Rollback)
    final previousMessages = state.messages;

    // 2. XÓA NGAY LẬP TỨC TRÊN UI (Lọc bỏ tin nhắn có id trùng khớp)
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != messageId).toList(),
    );

    try {
      // 3. Gọi API để xóa dưới Database (Bạn cần thêm hàm này trong MessageRepository)
      // await _repo.deleteMessage(messageId);

      // 4. (Tùy chọn) Bắn Socket sang máy người ấy để bên kia cũng thu hồi tin nhắn
      // _socket.emitDeleteMessage(messageId);
    } catch (e) {
      // 5. Nếu API lỗi, hoàn tác (Rollback) lại tin nhắn lên màn hình
      state = state.copyWith(
        messages: previousMessages,
        errorMessage: 'Không thể xóa tin nhắn: $e',
      );
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void clearUnread() => state = state.copyWith(hasUnread: false);
  void clearError() => state = state.copyWith(errorMessage: null);

  void emitTyping(String coupleId) =>
      _socket.emitTyping({'couple_id': coupleId, 'recipient_id': partnerId});

  void emitStopTyping(String coupleId) => _socket.emitStopTyping({
    'couple_id': coupleId,
    'recipient_id': partnerId,
  });
}

// ── Providers ─────────────────────────────────────────────────────────────────
final messageRepositoryProvider = Provider<MessageRepository>(
  (_) => MessageRepository(),
);

final socketClientProvider = Provider<SocketClient>((_) => SocketClient());

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  final socket = ref.read(socketClientProvider);
  final authState = ref.read(authProvider);
  return ChatNotifier(
    repo,
    socket,
    authState.user?.id ?? '',
    authState.couple?.partnerId(authState.user?.id ?? '') ?? '',
  );
});

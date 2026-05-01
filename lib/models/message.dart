// models/message.dart
// 📁 JAMOCHI_APP/lib/models/message.dart

class ChatMessage {
  final String id;
  final String senderId;
  final String? content;
  final String type; // 'text' | 'image' | 'locket'
  final String? mediaUrl; // URL ảnh nếu type == 'image'
  final String? reaction; // '❤️' | '😂' | '😮' | '😢' | '😡' | null
  final String? replyToId; // ID tin nhắn được reply
  final String? replyContent; // Nội dung tóm tắt của tin nhắn gốc
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    this.content,
    required this.type,
    this.mediaUrl,
    this.reaction,
    this.replyToId,
    this.replyContent,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content']?.toString(),
      type: json['type']?.toString() ?? 'text',
      mediaUrl: json['media_url']?.toString(),
      reaction: json['reaction']?.toString(),
      replyToId: json['reply_to_id']?.toString(),
      replyContent: (json['reply_to'] != null)
          ? json['reply_to']['content']?.toString()
          : (json['replyTo'] != null)
          ? json['replyTo']['content']?.toString()
          : null,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'content': content,
    'type': type,
    'media_url': mediaUrl,
    'reaction': reaction,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
  };

  // 🎯 PHƯƠNG THỨC COPYWITH MỚI ĐƯỢC THÊM VÀO
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? content,
    String? type,
    String? mediaUrl,
    String? reaction,
    String? replyToId,
    String? replyContent,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      reaction: reaction ?? this.reaction,
      replyToId: replyToId ?? this.replyToId,
      replyContent: replyContent ?? this.replyContent,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Copy với reaction mới (dùng khi user react)
  // 💡 Ghi chú: Có thể thay thế hàm này bằng copyWith(reaction: newReaction) 
  // nhưng giữ lại để không ảnh hưởng đến các file khác đang gọi hàm này.
  ChatMessage copyWithReaction(String? newReaction) => ChatMessage(
    id: id,
    senderId: senderId,
    content: content,
    type: type,
    mediaUrl: mediaUrl,
    reaction: newReaction,
    replyToId: replyToId,
    replyContent: replyContent,
    isRead: isRead,
    createdAt: createdAt,
  );

  // Thời gian hiển thị thân thiện
  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${createdAt.day}/${createdAt.month}';
  }

  bool get isImage => type == 'image';
  bool get isText => type == 'text';
}

// ── Online status ──────────────────────────────────────────────────────────────
class PartnerStatus {
  final bool isOnline;
  final DateTime? lastSeen;

  const PartnerStatus({required this.isOnline, this.lastSeen});

  String get label {
    if (isOnline) return 'Đang online 🟢';
    if (lastSeen == null) return 'Offline';
    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inMinutes < 1) return 'Vừa offline';
    if (diff.inMinutes < 60) return 'Offline ${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return 'Offline ${diff.inHours} giờ trước';
    return 'Offline lâu rồi 😴';
  }
}
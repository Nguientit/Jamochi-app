class ChatMessage {
  final String id;
  final String senderId;
  final String? content;
  final String type;
  final DateTime createdAt;

  ChatMessage({
    required this.id, required this.senderId, this.content,
    required this.type, required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'],
      type: json['type'] ?? 'text',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']).toLocal() 
          : DateTime.now(),
    );
  }
}
import './user.dart';

class Couple {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? coupleName;
  final String? anniversaryDate;
  final String? coupleAvatarUrl;
  final String status;

  final User? user1;
  final User? user2;

  const Couple({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.coupleName,
    this.anniversaryDate,
    this.coupleAvatarUrl,
    required this.status,
    this.user1, // Thêm vào constructor
    this.user2, // Thêm vào constructor
  });

  factory Couple.fromJson(Map<String, dynamic> json) {
    return Couple(
      id: json['id'] ?? '',
      user1Id: json['user_1_id'] ?? '',
      user2Id: json['user_2_id'] ?? '',
      coupleName: json['couple_name'],
      anniversaryDate: json['anniversary_date'],
      coupleAvatarUrl: json['couple_avatar_url'],
      status: json['status'] ?? 'pending',
      // 🎯 THÊM 2 DÒNG NÀY ĐỂ PARSE DỮ LIỆU TỪ BACKEND:
      user1: json['user1'] != null ? User.fromJson(json['user1']) : null,
      user2: json['user2'] != null ? User.fromJson(json['user2']) : null,
    );
  }

  Couple copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? coupleName,
    String? anniversaryDate,
    String? coupleAvatarUrl,
    String? status,
    User? user1,
    User? user2,
  }) {
    return Couple(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      coupleName: coupleName ?? this.coupleName,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      coupleAvatarUrl: coupleAvatarUrl ?? this.coupleAvatarUrl,
      status: status ?? this.status,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
    );
  }

  bool get isActive => status == 'active';

  String partnerId(String myId) => user1Id == myId ? user2Id : user1Id;
}

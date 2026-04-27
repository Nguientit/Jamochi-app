class Couple {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? coupleName;
  final String? anniversaryDate;
  final String? coupleAvatarUrl;
  final String status;

  const Couple({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.coupleName,
    this.anniversaryDate,
    this.coupleAvatarUrl,
    required this.status,
  });

  factory Couple.fromJson(Map<String, dynamic> json) {
    return Couple(
      id:               json['id']                ?? '',
      user1Id:          json['user_1_id']         ?? '',
      user2Id:          json['user_2_id']         ?? '',
      coupleName:       json['couple_name'],
      anniversaryDate:  json['anniversary_date'],
      coupleAvatarUrl:  json['couple_avatar_url'],
      status:           json['status']            ?? 'pending',
    );
  }

  bool get isActive => status == 'active';

  // Lấy ID của partner từ myId
  String partnerId(String myId) => user1Id == myId ? user2Id : user1Id;

  // Số ngày yêu nhau
  int? get daysTogetherSinceAnniversary {
    if (anniversaryDate == null) return null;
    final start = DateTime.tryParse(anniversaryDate!);
    if (start == null) return null;
    return DateTime.now().difference(start).inDays;
  }
}
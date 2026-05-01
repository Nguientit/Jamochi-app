class User {
  final String id;
  final String email;
  final String displayName;
  final String? nickname;
  final String? avatarUrl;
  final String? gender;
  final String? dateOfBirth;
  // Số đo (Vault)
  final double? heightCm;
  final double? weightKg;
  final double? bustCm;
  final double? waistCm;
  final double? hipCm;
  final String? bloodType;
  final double? shoeSize;
  final String? allergies;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.nickname,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.bustCm,
    this.waistCm,
    this.hipCm,
    this.bloodType,
    this.shoeSize,
    this.allergies,
  });

  // JSON → Object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? '',
      nickname: json['nickname'],
      avatarUrl: json['avatar_url']?.toString(),
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      bustCm: (json['bust_cm'] as num?)?.toDouble(),
      waistCm: (json['waist_cm'] as num?)?.toDouble(),
      hipCm: (json['hip_cm'] as num?)?.toDouble(),
      bloodType: json['blood_type'],
      shoeSize: (json['shoe_size'] as num?)?.toDouble(),
      allergies: json['allergies'],
    );
  }

  // Object → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'nickname': nickname,
    'avatar_url': avatarUrl,
    'gender': gender,
    'date_of_birth': dateOfBirth,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'bust_cm': bustCm,
    'waist_cm': waistCm,
    'hip_cm': hipCm,
    'blood_type': bloodType,
    'shoe_size': shoeSize,
    'allergies': allergies,
  };

  // Tên hiển thị ưu tiên nickname
  String get displayLabel => nickname ?? displayName;

  // Copy với fields mới
  User copyWith({
    String? displayName,
    String? nickname,
    String? avatarUrl,
    double? heightCm,
    double? weightKg,
    double? bustCm,
    double? waistCm,
    double? hipCm,
    String? bloodType,
    double? shoeSize,
    String? allergies,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bustCm: bustCm ?? this.bustCm,
      waistCm: waistCm ?? this.waistCm,
      hipCm: hipCm ?? this.hipCm,
      bloodType: bloodType ?? this.bloodType,
      shoeSize: shoeSize ?? this.shoeSize,
      allergies: allergies ?? this.allergies,
    );
  }
}

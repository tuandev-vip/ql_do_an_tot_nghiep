class UserModel {
  final String id;
  final String fullName;
  final String role;
  final String username; // Dùng làm Mã SV/GV
  final String? password;

  UserModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.username,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      username: json['username'] ?? '',
      password: json['password']?.toString(),
    );
  }

  // Hàm copyWith này cực kỳ quan trọng để reset mật khẩu mà không bị mất dữ liệu khác
  UserModel copyWith({String? password}) {
    return UserModel(
      id: id,
      fullName: fullName,
      role: role,
      username: username,
      password: password ?? this.password,
    );
  }
}

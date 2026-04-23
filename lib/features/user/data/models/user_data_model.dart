class UserDataModel {
  final String id;
  final String fullName;
  final String role;
  final String username; // Dùng làm Mã SV/GV
  final String? password;
  final bool isParticipating;

  UserDataModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.username,
    this.password,
    required this.isParticipating,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      // Sử dụng 'id' vì PHP đã Alias: user_id AS id
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      username: json['username'] ?? '',
      password: json['password']?.toString(),
      // Chuyển đổi giá trị TINYINT từ database sang bool
      isParticipating:
          (json['is_participating'] == 1 ||
          json['is_participating'] == '1' ||
          json['is_participating'] == true),
    );
  }

  // Hàm copyWith cho phép cập nhật từng phần dữ liệu mà không làm mất các thông tin khác
  UserDataModel copyWith({
    String? fullName,
    String? role,
    String? username,
    String? password,
    bool? isParticipating, // Thêm vào tham số để tránh lỗi Dead Code
  }) {
    return UserDataModel(
      id: id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      username: username ?? this.username,
      password: password ?? this.password,
      // Ưu tiên giá trị mới được truyền vào, nếu không sẽ giữ giá trị hiện tại
      isParticipating: isParticipating ?? this.isParticipating,
    );
  }
}

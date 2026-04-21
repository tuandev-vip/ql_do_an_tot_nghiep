class UserModel {
  final int userId;
  final String fullName;
  final String role;
  final String userCode; // Mã SV hoặc Mã GV
  final String deptName;
  final String facultyName;
  final String email;
  final String phone;
  final String? className; // Chỉ SV mới có
  final String? position; // Chỉ GV mới có

  UserModel({
    required this.userId,
    required this.fullName,
    required this.role,
    required this.userCode,
    required this.deptName,
    required this.facultyName,
    required this.email,
    required this.phone,
    this.className,
    this.position,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: int.parse(json['user_id'].toString()),
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      userCode: json['user_code'] ?? '',
      deptName: json['dept_name'] ?? '',
      facultyName: json['faculty_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      className: json['class_name'],
      position: json['position'],
    );
  }
}

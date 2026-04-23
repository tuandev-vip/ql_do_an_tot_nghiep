class TeacherModel {
  final String id;
  final String fullName;
  final String email;
  final String teacherCode;
  final String departmentName;
  final String phone;
  final int currentStudents;
  final int maxStudents;
  // THÊM DÒNG NÀY VÀO
  final String? myRegistrationStatus;

  TeacherModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.teacherCode,
    required this.departmentName,
    required this.phone,
    required this.currentStudents,
    required this.maxStudents,
    this.myRegistrationStatus, // THÊM DÒNG NÀY VÀO
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      teacherCode: json['teacher_code'] ?? '',
      departmentName: json['department_name'] ?? '',
      phone: json['phone'] ?? '',

      // SỬA TẠI ĐÂY: Dùng tên biến CamelCase cho đúng với Constructor
      currentStudents: int.tryParse(json['current_students'].toString()) ?? 0,
      maxStudents: int.tryParse(json['max_students'].toString()) ?? 8,

      // Nhận trạng thái từ SQL Subquery
      myRegistrationStatus: json['my_registration_status'],
    );
  }
}

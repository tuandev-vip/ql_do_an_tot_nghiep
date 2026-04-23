class TeacherModel {
  final String id;
  final String fullName;
  final String email;
  final String teacherCode;
  final String departmentName;
  final String phone;
  final int currentStudents;
  final int maxStudents;

  TeacherModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.teacherCode,
    required this.departmentName,
    required this.phone,
    required this.currentStudents,
    required this.maxStudents,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      teacherCode: json['teacher_code'] ?? '',
      departmentName: json['department_name'] ?? '',
      phone: json['phone'] ?? '',
      currentStudents: int.tryParse(json['current_students'].toString()) ?? 0,
      maxStudents: int.tryParse(json['max_students'].toString()) ?? 8,
    );
  }
}

class AutoAssignment {
  final String studentId;
  final String studentName;
  final String studentCode;
  final String? className;
  final String? teacherId;
  final String? teacherName;
  final String? status; // APPROVED, PENDING, REJECTED, hoặc null

  AutoAssignment({
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    this.className,
    this.teacherId,
    this.teacherName,
    this.status,
  });

  // Chuyển đổi từ JSON sang Object
  factory AutoAssignment.fromJson(Map<String, dynamic> json) {
    return AutoAssignment(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name'] ?? 'N/A',
      studentCode: json['student_code'] ?? 'N/A',
      className: json['class_name'],
      teacherId: json['teacher_id']?.toString(),
      teacherName: json['teacher_name'],
      status: json['status'],
    );
  }

  // Chuyển đổi từ Object sang JSON (nếu cần gửi dữ liệu lên)
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'student_code': studentCode,
      'class_name': className,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'status': status,
    };
  }

  // Getter hỗ trợ logic lọc nhanh trên UI
  bool get hasAdvisor => status == 'APPROVED' && teacherId != null;
  bool get isWaiting => status == 'PENDING';
  bool get needsAssignment => status == null || status == 'REJECTED';
}

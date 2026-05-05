class EvaluationStudentModel {
  final String studentId;
  final String studentName;
  final String studentCode;
  final String? topic;
  final int progress;
  final int totalProgress;
  final bool hasNotification;

  EvaluationStudentModel({
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    this.topic,
    required this.progress,
    required this.totalProgress,
    required this.hasNotification,
  });

  factory EvaluationStudentModel.fromJson(Map<String, dynamic> json) {
    return EvaluationStudentModel(
      studentId: json['student_id'] ?? '',
      studentName: json['student_name'] ?? 'Chưa rõ',
      studentCode: json['student_code'] ?? 'Chưa rõ',
      topic: json['topic'], // Có thể null
      progress: json['progress'] ?? 0,
      totalProgress: json['total_progress'] ?? 10,
      hasNotification:
          json['has_notification'] == true || json['has_notification'] == 1,
    );
  }

  // Chuyển ngược lại thành Map để xài chung với UI cũ nếu cần
  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'student_code': studentCode,
      'topic': topic,
      'progress': progress,
      'total_progress': totalProgress,
      'has_notification': hasNotification,
    };
  }
}

abstract class StudentDashboardState {}

class StudentDashboardInitial extends StudentDashboardState {}

class StudentDashboardLoading extends StudentDashboardState {}

class StudentDashboardLoaded extends StudentDashboardState {
  final bool hasBatch;
  final String? advisorName;
  final String? topicName;

  // 💡 Danh sách các mốc thời gian (Tên mốc : Ngày hạn nộp)
  final Map<String, DateTime?> deadlines;

  // 💡 Chấm đỏ thần thánh
  final bool hasUnread;

  StudentDashboardLoaded({
    required this.hasBatch,
    this.advisorName,
    this.topicName,
    required this.deadlines,
    this.hasUnread = false,
  });
}

class StudentDashboardError extends StudentDashboardState {
  final String message;
  StudentDashboardError(this.message);
}

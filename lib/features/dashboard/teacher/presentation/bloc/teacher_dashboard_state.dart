abstract class TeacherDashboardState {}

class DashboardLoading extends TeacherDashboardState {}

class DashboardLoaded extends TeacherDashboardState {
  final String viewStatus;
  final int totalStudents;
  final List<dynamic> statistics;
  final bool hasUnread;
  DashboardLoaded({
    required this.viewStatus,
    required this.totalStudents,
    required this.statistics,
    this.hasUnread = false,
  });
}

class DashboardError extends TeacherDashboardState {
  final String message;
  DashboardError(this.message);
}

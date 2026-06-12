abstract class StudentDashboardEvent {}

class LoadStudentDashboardStats extends StudentDashboardEvent {
  final String studentId;
  LoadStudentDashboardStats(this.studentId);
}

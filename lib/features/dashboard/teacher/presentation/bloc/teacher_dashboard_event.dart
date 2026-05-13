abstract class TeacherDashboardEvent {}

class FetchTeacherDashboard extends TeacherDashboardEvent {
  final int teacherId;
  FetchTeacherDashboard(this.teacherId);
}

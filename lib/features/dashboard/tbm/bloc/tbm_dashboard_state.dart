abstract class TbmDashboardState {}

class TbmDashboardInitial extends TbmDashboardState {}

class TbmDashboardLoading extends TbmDashboardState {}

class TbmDashboardLoaded extends TbmDashboardState {
  final int totalStudents;
  final int totalTeachers;
  final int noAdvisor;
  final int missingMembers;

  TbmDashboardLoaded({
    required this.totalStudents,
    required this.totalTeachers,
    required this.noAdvisor,
    required this.missingMembers,
  });
}

class TbmDashboardError extends TbmDashboardState {
  final String message;

  TbmDashboardError(this.message);
}

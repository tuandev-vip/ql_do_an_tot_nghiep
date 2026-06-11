abstract class TbmDashboardEvent {}

class LoadTbmDashboardStats extends TbmDashboardEvent {
  final String deptId;

  LoadTbmDashboardStats(this.deptId);
}

class GenerateAIStatsEvent extends TbmDashboardEvent {
  final String deptId;
  final int weekNum;

  GenerateAIStatsEvent({required this.deptId, required this.weekNum});
}

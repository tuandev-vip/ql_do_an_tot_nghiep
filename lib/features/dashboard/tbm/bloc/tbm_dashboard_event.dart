abstract class TbmDashboardEvent {}

class LoadTbmDashboardStats extends TbmDashboardEvent {
  final String deptId;

  LoadTbmDashboardStats(this.deptId);
}

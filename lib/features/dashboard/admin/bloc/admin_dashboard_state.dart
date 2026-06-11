abstract class AdminDashboardState {}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  // 💡 CHÌA KHÓA CHẤM ĐỎ CỦA ADMIN NẰM Ở ĐÂY
  final bool hasUnread;

  AdminDashboardLoaded({this.hasUnread = false});

  AdminDashboardLoaded copyWith({bool? hasUnread}) {
    return AdminDashboardLoaded(hasUnread: hasUnread ?? this.hasUnread);
  }
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  AdminDashboardError(this.message);
}

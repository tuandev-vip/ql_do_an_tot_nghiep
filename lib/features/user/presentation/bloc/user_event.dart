abstract class UserEvent {}

class FetchUsersEvent extends UserEvent {
  final bool isRefresh; // 💡 Kích hoạt để reset về trang 1
  FetchUsersEvent({this.isRefresh = false});
}

class SearchUserEvent extends UserEvent {
  final String query;
  SearchUserEvent(this.query);
}

class ResetPasswordEvent extends UserEvent {
  final String userId;
  ResetPasswordEvent(this.userId);
}

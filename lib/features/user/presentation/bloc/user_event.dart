abstract class UserEvent {}

class FetchUsersEvent extends UserEvent {}

class SearchUserEvent extends UserEvent {
  final String query;
  SearchUserEvent(this.query);
}

class ResetPasswordEvent extends UserEvent {
  final String userId;
  ResetPasswordEvent(this.userId);
}

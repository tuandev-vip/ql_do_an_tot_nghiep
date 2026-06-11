abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final String userId;
  final String role;

  LoadNotifications({required this.userId, required this.role});
}

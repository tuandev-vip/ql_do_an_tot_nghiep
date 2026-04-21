// lib/features/auth/presentation/bloc/auth_event.dart
abstract class AuthEvent {}

// Sự kiện khi người dùng nhấn nút Đăng nhập
class LoginSubmitted extends AuthEvent {
  final String username;
  final String password;
  LoginSubmitted({required this.username, required this.password});
}

// Sự kiện khi người dùng nhấn Đăng xuất
class LogoutRequested extends AuthEvent {}

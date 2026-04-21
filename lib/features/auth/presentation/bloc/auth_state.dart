// lib/features/auth/presentation/bloc/auth_state.dart
import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {} // Đang xoay vòng tròn chờ API

class AuthSuccess extends AuthState {
  final UserModel user; // Đăng nhập xong thì có dữ liệu User
  AuthSuccess({required this.user});
}

class AuthFailure extends AuthState {
  final String message; // Lỗi thì có tin nhắn thông báo
  AuthFailure({required this.message});
}

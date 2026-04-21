// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Xử lý sự kiện Đăng nhập
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading()); // Báo cho UI hiện vòng xoay Loading
      try {
        final user = await authRepository.login(event.username, event.password);
        if (user != null) {
          emit(AuthSuccess(user: user)); // Đăng nhập thành công
        } else {
          emit(AuthFailure(message: "Không có dữ liệu trả về"));
        }
      } catch (e) {
        // e chính là Exception(result['message']) từ Repository trả về
        emit(AuthFailure(message: e.toString().replaceAll("Exception: ", "")));
      }
    });

    // Xử lý sự kiện Đăng xuất
    on<LogoutRequested>((event, emit) {
      emit(AuthInitial());
    });
  }
}

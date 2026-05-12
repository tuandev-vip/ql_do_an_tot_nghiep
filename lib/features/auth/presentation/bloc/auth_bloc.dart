// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 Bắt buộc import thêm cái này
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
          // 💡 LƯU MÃ BỘ MÔN VÀO BỘ NHỚ MÁY Ở ĐÂY
          final prefs = await SharedPreferences.getInstance();
          // Giả sử trong file UserModel của ông, thuộc tính đó tên là deptId.
          // Nếu ông đặt tên khác (như dept_id hay departmentId) thì nhớ sửa lại cho khớp nhé!
          await prefs.setString('dept_code', user.deptId ?? "");

          emit(AuthSuccess(user: user)); // Đăng nhập thành công
        } else {
          emit(AuthFailure(message: "Không có dữ liệu trả về"));
        }
      } catch (e) {
        emit(AuthFailure(message: e.toString().replaceAll("Exception: ", "")));
      }
    });

    // Xử lý sự kiện Đăng xuất
    on<LogoutRequested>((event, emit) async {
      // 💡 XOÁ MÃ BỘ MÔN KHI ĐĂNG XUẤT ĐỂ TRÁNH LỖI KHI ĐĂNG NHẬP ACC KHÁC
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('dept_code');

      emit(AuthInitial());
    });
  }
}

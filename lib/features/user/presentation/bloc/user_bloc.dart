import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_event.dart';
import 'package:ql_do_an_tot_nghiep/features/user/data/models/user_model.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  List<UserModel> _allUsers = []; // Biến static trong Bloc để giữ danh sách gốc

  UserBloc() : super(UserInitial()) {
    // 1. Lấy danh sách ban đầu
    on<FetchUsersEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final response = await http.get(
          Uri.parse("http://192.168.1.109/ql_do_an_api/admin/get_users.php"),
        );
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          _allUsers = data.map((json) => UserModel.fromJson(json)).toList();
          _emitLoadedState(emit);
        }
      } catch (e) {
        emit(UserError("Không thể kết nối Server"));
      }
    });

    // 2. Tìm kiếm Local (Không gọi API)
    on<SearchUserEvent>((event, emit) {
      final query = event.query.toLowerCase();
      final filtered = _allUsers.where((u) {
        return u.fullName.toLowerCase().contains(query) ||
            u.username.toLowerCase().contains(query);
      }).toList();

      // Tính toán lại số lượng dựa trên danh sách gốc
      int tCount = _allUsers.where((u) => u.role != 'STUDENT').length;
      int sCount = _allUsers.where((u) => u.role == 'STUDENT').length;

      emit(
        UserLoaded(users: filtered, teacherCount: tCount, studentCount: sCount),
      );
    });

    // 3. Reset mật khẩu
    on<ResetPasswordEvent>((event, emit) async {
      try {
        // 1. Gửi ID chính xác lên Server (Lúc này ID đã có giá trị nhờ PHP Alias AS id)
        final response = await http.post(
          Uri.parse(
            "http://192.168.1.109/ql_do_an_api/admin/reset_password.php",
          ),
          body: {"id": event.userId},
        );

        if (response.statusCode == 200) {
          // 2. Cập nhật mật khẩu mới vào danh sách đang hiển thị để user thấy ngay
          int index = _allUsers.indexWhere((u) => u.id == event.userId);
          if (index != -1) {
            _allUsers[index] = _allUsers[index].copyWith(password: "123456");
          }

          // 3. Tính toán lại số lượng
          int t = _allUsers.where((u) => u.role != 'STUDENT').length;
          int s = _allUsers.where((u) => u.role == 'STUDENT').length;

          // 4. Phát ra State thành công kèm theo dữ liệu mới nhất
          emit(
            PasswordResetSuccess(
              message: "Đã reset mật khẩu thành công!",
              users: List.from(
                _allUsers,
              ), // Clone lại list để UI nhận diện thay đổi
              teacherCount: t,
              studentCount: s,
            ),
          );
        }
      } catch (e) {
        emit(UserError("Không thể kết nối Server để reset"));
      }
    });
  }

  void _emitLoadedState(Emitter<UserState> emit) {
    int tCount = _allUsers.where((u) => u.role != 'STUDENT').length;
    int sCount = _allUsers.where((u) => u.role == 'STUDENT').length;
    emit(
      UserLoaded(users: _allUsers, teacherCount: tCount, studentCount: sCount),
    );
  }
}

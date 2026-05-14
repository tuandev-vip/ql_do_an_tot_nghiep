import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // 💡 Thêm thư viện này
import 'user_event.dart';
import 'package:ql_do_an_tot_nghiep/features/user/data/models/user_data_model.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  List<UserDataModel> _allUsers = [];
  int _currentPage = 1;
  final int _limit = 5;
  String _currentSearchQuery = '';

  UserBloc() : super(UserInitial()) {
    // 1. LẤY & PHÂN TRANG DANH SÁCH TỪ API
    on<FetchUsersEvent>((event, emit) async {
      if (event.isRefresh) {
        _currentPage = 1;
        emit(UserLoading());
      }

      final currentState = state;
      if (currentState is UserLoaded &&
          currentState.hasReachedMax &&
          !event.isRefresh) {
        return;
      }

      if (currentState is UserLoaded && !event.isRefresh) {
        emit(currentState.copyWith(isFetchingMore: true));
      } else if (!event.isRefresh) {
        emit(UserLoading());
      }

      try {
        // 💡 Gắn param page, limit, search vào URL
        final String apiUrl =
            "${AppUrls.urlFetchUsers}?page=$_currentPage&limit=$_limit&search=$_currentSearchQuery";
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          final data = await compute(jsonDecode, response.body);
          if (data['status'] == 'success') {
            final List rawUsers = data['users'] ?? [];
            final List<UserDataModel> newUsers = rawUsers
                .map((json) => UserDataModel.fromJson(json))
                .toList();

            if (currentState is UserLoaded && !event.isRefresh) {
              _allUsers = List.of(currentState.users)..addAll(newUsers);
              emit(
                currentState.copyWith(
                  users: _allUsers,
                  hasReachedMax: newUsers.length < _limit,
                  isFetchingMore: false,
                ),
              );
            } else {
              _allUsers = newUsers;
              emit(
                UserLoaded(
                  users: _allUsers,
                  teacherCount: data['teacher_count'] ?? 0,
                  studentCount: data['student_count'] ?? 0,
                  hasReachedMax: newUsers.length < _limit,
                  isFetchingMore: false,
                ),
              );
            }
            _currentPage++;
          } else {
            emit(UserError(data['message'] ?? "Lỗi dữ liệu"));
          }
        } else {
          emit(UserError("Lỗi server"));
        }
      } catch (e) {
        emit(UserError("Không thể kết nối Server"));
      }
    });

    // 2. TÌM KIẾM (Gắn query và gọi lại trang 1)
    on<SearchUserEvent>((event, emit) {
      _currentSearchQuery = event.query;
      add(FetchUsersEvent(isRefresh: true));
    });

    // 3. RESET MẬT KHẨU
    on<ResetPasswordEvent>((event, emit) async {
      try {
        final response = await http.post(
          Uri.parse(AppUrls.urlResetpassword),
          body: {"id": event.userId},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            int index = _allUsers.indexWhere((u) => u.id == event.userId);
            if (index != -1) {
              _allUsers[index] = _allUsers[index].copyWith(password: "123456");
            }

            if (state is UserLoaded) {
              final currentState = state as UserLoaded;
              emit(
                PasswordResetSuccess(
                  message: "Đã reset mật khẩu thành công!",
                  users: List.from(_allUsers),
                  teacherCount: currentState.teacherCount,
                  studentCount: currentState.studentCount,
                  hasReachedMax: currentState.hasReachedMax,
                ),
              );
            }
          }
        }
      } catch (e) {
        emit(UserError("Không thể kết nối Server để reset"));
      }
    });
  }
}

import 'package:ql_do_an_tot_nghiep/features/user/data/models/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> users; // Danh sách hiển thị (đã lọc hoặc tất cả)
  final int teacherCount;
  final int studentCount;
  UserLoaded({
    required this.users,
    required this.teacherCount,
    required this.studentCount,
  });
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class PasswordResetSuccess extends UserLoaded {
  final String message;
  PasswordResetSuccess({
    required this.message,
    required super.users,
    required super.teacherCount,
    required super.studentCount,
  });
}

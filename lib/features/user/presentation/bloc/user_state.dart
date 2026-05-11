import 'package:ql_do_an_tot_nghiep/features/user/data/models/user_data_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserDataModel> users;
  final int teacherCount;
  final int studentCount;
  final bool hasReachedMax; // 💡 Đã hết data chưa
  final bool isFetchingMore; // 💡 Đang xoay xoay dưới đáy không

  UserLoaded({
    required this.users,
    required this.teacherCount,
    required this.studentCount,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  // 💡 Hàm Copy hỗ trợ cuộn mượt
  UserLoaded copyWith({
    List<UserDataModel>? users,
    int? teacherCount,
    int? studentCount,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      teacherCount: teacherCount ?? this.teacherCount,
      studentCount: studentCount ?? this.studentCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
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
    super.hasReachedMax,
    super.isFetchingMore,
  });
}

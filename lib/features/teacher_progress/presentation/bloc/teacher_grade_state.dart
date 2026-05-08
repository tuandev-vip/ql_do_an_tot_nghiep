abstract class TeacherGradeState {}

class TeacherGradeInitial extends TeacherGradeState {}

class TeacherGradeLoading extends TeacherGradeState {}

// Trạng thái đã load xong dữ liệu
class TeacherGradeLoaded extends TeacherGradeState {
  final String timeStatus;
  final String openTime;
  final String closeTime;
  final double? score;

  TeacherGradeLoaded({
    required this.timeStatus,
    required this.openTime,
    required this.closeTime,
    this.score,
  });
}

// Trạng thái lỗi (Chưa có đợt, lỗi mạng...)
class TeacherGradeError extends TeacherGradeState {
  final String message;
  TeacherGradeError(this.message);
}

// Trạng thái update điểm thành công
class TeacherGradeUpdateSuccess extends TeacherGradeState {
  final String message;
  TeacherGradeUpdateSuccess(this.message);
}

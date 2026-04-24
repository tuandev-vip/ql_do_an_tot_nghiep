import '../../../user/data/models/teacher_model.dart';

abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

// Trạng thái đã tải xong danh sách giảng viên
class TeachersLoaded extends RegistrationState {
  final List<TeacherModel> teachers;
  TeachersLoaded(this.teachers);
}

// Trạng thái khi đã gửi yêu cầu thành công (Ảnh 3)
class RegistrationSubmitting extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  final String message;
  final String teacherId;
  final List<TeacherModel> teachers;
  RegistrationSuccess(this.message, this.teacherId, this.teachers);
}

class RegistrationError extends RegistrationState {
  final String message;
  final List<TeacherModel> teachers;
  RegistrationError(this.message, this.teachers);
}

// lấy trạng thái và hạn chót để testmode
class RegistrationExpired extends RegistrationState {
  final String batchName;
  final String deadline;
  RegistrationExpired(this.batchName, this.deadline);
}

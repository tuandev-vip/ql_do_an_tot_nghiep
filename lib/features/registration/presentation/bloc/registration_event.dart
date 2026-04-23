abstract class RegistrationEvent {}

// Sự kiện lấy danh sách giảng viên tham gia đợt
class FetchTeachersEvent extends RegistrationEvent {
  final String studentId;

  FetchTeachersEvent(this.studentId);
}

// Sự kiện sinh viên nhấn nút Đăng ký (Ảnh 2)
class SubmitRegistrationEvent extends RegistrationEvent {
  final String teacherId;
  final String topicDirection;
  final String studentId;
  SubmitRegistrationEvent(this.teacherId, this.topicDirection, this.studentId);
}

class SearchTeacherEvent extends RegistrationEvent {
  final String query;
  SearchTeacherEvent(this.query);
}

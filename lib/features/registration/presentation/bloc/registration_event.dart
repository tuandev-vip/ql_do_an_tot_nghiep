abstract class RegistrationEvent {}

// Sự kiện lấy danh sách giảng viên tham gia đợt
class FetchTeachersEvent extends RegistrationEvent {}

// Sự kiện sinh viên nhấn nút Đăng ký (Ảnh 2)
class SubmitRegistrationEvent extends RegistrationEvent {
  final String teacherId;
  final String topicDirection;
  SubmitRegistrationEvent(this.teacherId, this.topicDirection);
}

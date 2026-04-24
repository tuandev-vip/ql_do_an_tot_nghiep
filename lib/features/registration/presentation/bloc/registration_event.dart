abstract class RegistrationEvent {}

// role Student
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

// Role Teacher
// Lấy toàn bộ danh sách sinh viên (cả chờ duyệt và đã duyệt) của giảng viên
class FetchAdvisorStudentsEvent extends RegistrationEvent {
  final String teacherId;
  FetchAdvisorStudentsEvent(this.teacherId);
}

// Giảng viên xử lý Duyệt/Từ chối
class UpdateStudentStatusEvent extends RegistrationEvent {
  final String regId;
  final String status; // 'APPROVED' hoặc 'REJECTED'
  final String teacherId;
  UpdateStudentStatusEvent(this.regId, this.status, this.teacherId);
}

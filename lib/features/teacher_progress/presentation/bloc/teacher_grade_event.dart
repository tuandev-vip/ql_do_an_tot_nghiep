abstract class TeacherGradeEvent {}

// Event 1: Lấy thông tin điểm và thời gian
class FetchGradeInfo extends TeacherGradeEvent {
  final String studentId;
  FetchGradeInfo(this.studentId);
}

// Event 2: Bấm nút lưu điểm
class SubmitTeacherGrade extends TeacherGradeEvent {
  final String studentId;
  final double score;
  SubmitTeacherGrade(this.studentId, this.score);
}

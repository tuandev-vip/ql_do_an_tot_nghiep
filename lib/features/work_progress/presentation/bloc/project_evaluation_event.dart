abstract class ProjectEvaluationEvent {}

// Sự kiện lấy danh sách sinh viên theo ID Giảng viên
class FetchEvaluationStudents extends ProjectEvaluationEvent {
  final String teacherId;
  FetchEvaluationStudents(this.teacherId);
}

// Sự kiện tìm kiếm sinh viên trên thanh Search
class SearchEvaluationStudent extends ProjectEvaluationEvent {
  final String query;
  SearchEvaluationStudent(this.query);
}

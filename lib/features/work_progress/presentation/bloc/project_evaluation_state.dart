import '../../data/models/evaluation_student_model.dart';

abstract class ProjectEvaluationState {}

class EvaluationInitial extends ProjectEvaluationState {}

class EvaluationLoading extends ProjectEvaluationState {}

// Trạng thái load thành công, chứa danh sách sinh viên
class EvaluationLoaded extends ProjectEvaluationState {
  final List<EvaluationStudentModel> students;
  EvaluationLoaded(this.students);
}

// Trạng thái lỗi mạng, lỗi API...
class EvaluationError extends ProjectEvaluationState {
  final String message;
  EvaluationError(this.message);
}

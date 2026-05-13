abstract class TeacherCouncilState {}

class TeacherCouncilInitial extends TeacherCouncilState {}

class TeacherCouncilLoading extends TeacherCouncilState {}

class TeacherCouncilLoaded extends TeacherCouncilState {
  final String viewStatus; // NO_BATCH, NO_COUNCIL, HAS_COUNCIL
  final List<dynamic> councils;
  TeacherCouncilLoaded({required this.viewStatus, required this.councils});
}

class TeacherCouncilError extends TeacherCouncilState {
  final String message;
  TeacherCouncilError(this.message);
}

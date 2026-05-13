abstract class StudentCouncilEvent {}

class FetchStudentCouncilEvent extends StudentCouncilEvent {
  final int studentId;
  final bool isSchoolLevel;
  final bool isRefresh;

  FetchStudentCouncilEvent({
    required this.studentId,
    required this.isSchoolLevel,
    this.isRefresh = false,
  });
}

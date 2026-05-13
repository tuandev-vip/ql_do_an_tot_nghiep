abstract class TeacherCouncilEvent {}

class FetchTeacherCouncilsEvent extends TeacherCouncilEvent {
  final int teacherId;
  final bool isSchoolLevel;
  FetchTeacherCouncilsEvent({
    required this.teacherId,
    required this.isSchoolLevel,
  });
}

abstract class TeacherCouncilDetailEvent {}

class FetchCouncilDetailsEvent extends TeacherCouncilDetailEvent {
  final int councilId;
  final bool isRefresh;
  FetchCouncilDetailsEvent({required this.councilId, this.isRefresh = false});
}

abstract class TbmCouncilDetailEvent {}

class FetchStudentsEvent extends TbmCouncilDetailEvent {
  final int councilId;
  final bool isRefresh;
  FetchStudentsEvent(this.councilId, {this.isRefresh = false});
}

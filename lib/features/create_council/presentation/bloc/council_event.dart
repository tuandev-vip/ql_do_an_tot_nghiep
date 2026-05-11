abstract class CouncilEvent {}

class FetchCouncilInfoEvent extends CouncilEvent {
  final bool isSchoolLevel;
  final bool isRefresh;
  FetchCouncilInfoEvent({this.isSchoolLevel = false, this.isRefresh = false});
}

class AutoCreateCouncilEvent extends CouncilEvent {
  final int capacity; // Chỉ cần sức chứa
  AutoCreateCouncilEvent(this.capacity);
}

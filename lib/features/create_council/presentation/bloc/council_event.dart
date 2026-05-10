abstract class CouncilEvent {}

class FetchCouncilInfoEvent extends CouncilEvent {
  final bool isSchoolLevel;
  FetchCouncilInfoEvent({this.isSchoolLevel = false});
}

class AutoCreateCouncilEvent extends CouncilEvent {
  final int capacity; // Chỉ cần sức chứa
  AutoCreateCouncilEvent(this.capacity);
}

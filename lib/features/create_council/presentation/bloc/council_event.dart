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

class AssignDepartmentEvent extends CouncilEvent {
  final int councilId;
  final String departmentData; // Lưu chuỗi JSON: {"CNPM":2, "MATTT":1}
  AssignDepartmentEvent(this.councilId, this.departmentData);
}

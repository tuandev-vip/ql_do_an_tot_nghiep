abstract class CouncilEvent {}

class FetchCouncilInfoEvent extends CouncilEvent {
  final bool isSchoolLevel;
  final bool isRefresh;
  FetchCouncilInfoEvent({this.isSchoolLevel = false, this.isRefresh = false});
}

class AutoCreateCouncilEvent extends CouncilEvent {
  final int capacity; // Chỉ cần sức chứa
  final bool isSchoolLevel;
  AutoCreateCouncilEvent(this.capacity, this.isSchoolLevel);
}

class AssignDepartmentEvent extends CouncilEvent {
  final int councilId;
  final String departmentData; // Lưu chuỗi JSON: {"CNPM":2, "MATTT":1}
  final bool isSchoolLevel;
  AssignDepartmentEvent(
    this.councilId,
    this.departmentData,
    this.isSchoolLevel,
  );
}

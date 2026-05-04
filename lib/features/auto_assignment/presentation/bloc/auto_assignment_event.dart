abstract class AutoAssignmentEvent {}

class FetchAutoAssignmentStudents extends AutoAssignmentEvent {
  final String filter; // all, not_assigned, assigned
  final String deptId;
  FetchAutoAssignmentStudents(this.filter, this.deptId);
}

class TriggerAutoAssign extends AutoAssignmentEvent {
  final String deptId;
  TriggerAutoAssign(this.deptId);
}

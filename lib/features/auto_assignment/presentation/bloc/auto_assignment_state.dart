import '../../data/models/auto_assignment_model.dart';

abstract class AutoAssignmentState {}

class AutoAssignmentInitial extends AutoAssignmentState {}

class AutoAssignmentLoading extends AutoAssignmentState {}

class AutoAssignmentLoaded extends AutoAssignmentState {
  final List<AutoAssignment> students;
  AutoAssignmentLoaded(this.students);
}

class AutoAssignmentError extends AutoAssignmentState {
  final String message;
  AutoAssignmentError(this.message);
}

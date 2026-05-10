abstract class CouncilState {}

class CouncilInitial extends CouncilState {}

class CouncilLoading extends CouncilState {}

class CouncilLoaded extends CouncilState {
  final String timeStatus;
  final int totalStudents;
  final List<dynamic> councils;

  CouncilLoaded({
    required this.timeStatus,
    required this.totalStudents,
    required this.councils,
  });
}

class CouncilActionSuccess extends CouncilState {
  final String message;
  CouncilActionSuccess(this.message);
}

class CouncilError extends CouncilState {
  final String message;
  CouncilError(this.message);
}

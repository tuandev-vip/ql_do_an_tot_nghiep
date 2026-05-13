abstract class StudentCouncilState {}

class StudentCouncilInitial extends StudentCouncilState {}

class StudentCouncilLoading extends StudentCouncilState {}

class StudentCouncilLoaded extends StudentCouncilState {
  final String viewStatus; // NO_BATCH, NO_COUNCIL, HAS_COUNCIL
  final Map<String, dynamic>? councilInfo;
  final List<dynamic> students;
  final bool hasReachedMax;
  final bool isFetchingMore;

  StudentCouncilLoaded({
    required this.viewStatus,
    this.councilInfo,
    required this.students,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  StudentCouncilLoaded copyWith({
    String? viewStatus,
    Map<String, dynamic>? councilInfo,
    List<dynamic>? students,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return StudentCouncilLoaded(
      viewStatus: viewStatus ?? this.viewStatus,
      councilInfo: councilInfo ?? this.councilInfo,
      students: students ?? this.students,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class StudentCouncilError extends StudentCouncilState {
  final String message;
  StudentCouncilError(this.message);
}

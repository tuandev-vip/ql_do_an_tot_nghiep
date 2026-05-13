abstract class TeacherCouncilDetailState {}

class DetailInitial extends TeacherCouncilDetailState {}

class DetailLoading extends TeacherCouncilDetailState {}

class DetailLoaded extends TeacherCouncilDetailState {
  final Map<String, dynamic>? councilInfo;
  final List<dynamic> students;
  final bool hasReachedMax;
  final bool isFetchingMore;

  DetailLoaded({
    this.councilInfo,
    required this.students,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  DetailLoaded copyWith({
    Map<String, dynamic>? councilInfo,
    List<dynamic>? students,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return DetailLoaded(
      councilInfo: councilInfo ?? this.councilInfo,
      students: students ?? this.students,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class DetailError extends TeacherCouncilDetailState {
  final String message;
  DetailError(this.message);
}

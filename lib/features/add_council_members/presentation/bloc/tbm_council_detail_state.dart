abstract class TbmCouncilDetailState {}

class DetailInitial extends TbmCouncilDetailState {}

class DetailLoading extends TbmCouncilDetailState {}

class DetailLoaded extends TbmCouncilDetailState {
  final List<dynamic> students;
  final bool hasReachedMax;
  final bool isFetchingMore;

  DetailLoaded({
    required this.students,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  DetailLoaded copyWith({
    List<dynamic>? students,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return DetailLoaded(
      students: students ?? this.students,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class DetailError extends TbmCouncilDetailState {
  final String message;
  DetailError(this.message);
}

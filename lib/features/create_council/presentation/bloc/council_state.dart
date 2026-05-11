abstract class CouncilState {}

class CouncilInitial extends CouncilState {}

class CouncilLoading extends CouncilState {}

class CouncilLoaded extends CouncilState {
  final String timeStatus;
  final int totalStudents;
  final List<dynamic> councils;
  final bool hasReachedMax; // 💡 Cờ báo hiệu đã tải hết sạch data chưa
  final bool isFetchingMore;
  CouncilLoaded({
    required this.timeStatus,
    required this.totalStudents,
    required this.councils,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  CouncilLoaded copyWith({
    String? timeStatus,
    int? totalStudents,
    List<dynamic>? councils,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return CouncilLoaded(
      timeStatus: timeStatus ?? this.timeStatus,
      totalStudents: totalStudents ?? this.totalStudents,
      councils: councils ?? this.councils,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class CouncilActionSuccess extends CouncilState {
  final String message;
  CouncilActionSuccess(this.message);
}

class CouncilError extends CouncilState {
  final String message;
  CouncilError(this.message);
}

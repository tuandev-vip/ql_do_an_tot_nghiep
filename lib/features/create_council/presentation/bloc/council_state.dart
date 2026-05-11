abstract class CouncilState {}

class CouncilInitial extends CouncilState {}

class CouncilLoading extends CouncilState {}

class CouncilLoaded extends CouncilState {
  final String createTimeStatus; // 💡 Đổi tên
  final String assignTimeStatus; // 💡 Thêm biến
  final int totalStudents;
  final List<dynamic> councils;
  final bool hasReachedMax;
  final bool isFetchingMore;

  CouncilLoaded({
    required this.createTimeStatus,
    required this.assignTimeStatus,
    required this.totalStudents,
    required this.councils,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  CouncilLoaded copyWith({
    String? createTimeStatus,
    String? assignTimeStatus,
    int? totalStudents,
    List<dynamic>? councils,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return CouncilLoaded(
      createTimeStatus: createTimeStatus ?? this.createTimeStatus,
      assignTimeStatus: assignTimeStatus ?? this.assignTimeStatus,
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

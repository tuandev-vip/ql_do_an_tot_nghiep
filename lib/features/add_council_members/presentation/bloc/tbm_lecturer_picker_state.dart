abstract class TbmLecturerPickerState {}

class PickerInitial extends TbmLecturerPickerState {}

class PickerLoading extends TbmLecturerPickerState {}

class PickerLoaded extends TbmLecturerPickerState {
  final List<dynamic> lecturers;
  final bool hasReachedMax;
  final bool isFetchingMore;

  PickerLoaded({
    required this.lecturers,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  PickerLoaded copyWith({
    List<dynamic>? lecturers,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return PickerLoaded(
      lecturers: lecturers ?? this.lecturers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class PickerError extends TbmLecturerPickerState {
  final String message;
  PickerError(this.message);
}

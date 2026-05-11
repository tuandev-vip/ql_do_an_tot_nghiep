abstract class TbmCouncilState {}

class TbmCouncilInitial extends TbmCouncilState {}

class TbmCouncilLoading extends TbmCouncilState {}

class TbmCouncilLoaded extends TbmCouncilState {
  final List<dynamic> councils;
  final String
  assignTimeStatus; // Trạng thái thời gian: OPEN, LOCKED, OVERDUE, NO_BATCH

  TbmCouncilLoaded({required this.councils, required this.assignTimeStatus});
}

class TbmCouncilError extends TbmCouncilState {
  final String message;
  TbmCouncilError(this.message);
}

abstract class TbmCouncilEvent {}

class FetchTbmCouncilsEvent extends TbmCouncilEvent {
  final bool isSchoolLevel; // Để dành mốt tái sử dụng cho cấp trường
  FetchTbmCouncilsEvent({required this.isSchoolLevel});
}

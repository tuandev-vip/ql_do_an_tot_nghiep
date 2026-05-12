abstract class TbmLecturerPickerEvent {}

class FetchLecturersEvent extends TbmLecturerPickerEvent {
  final String deptCode;
  final bool isRefresh;
  FetchLecturersEvent(this.deptCode, {this.isRefresh = false});
}

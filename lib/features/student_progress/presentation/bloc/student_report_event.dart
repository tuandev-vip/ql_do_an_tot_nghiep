abstract class StudentReportEvent {}

// 1. Sự kiện load dữ liệu (Đã có)
class LoadReportsEvent extends StudentReportEvent {
  final String studentId;
  LoadReportsEvent(this.studentId);
}

// 2. Sự kiện chọn tuần (Đã có)
class SelectWeekEvent extends StudentReportEvent {
  final int selectedWeek;
  SelectWeekEvent(this.selectedWeek);
}

// 3. THÊM MỚI: Sự kiện nộp báo cáo (Đây là cái ông đang thiếu)
class SubmitReportEvent extends StudentReportEvent {
  final String studentId;
  final String studentName; // Để PHP đặt tên file: ..._Nguyen_Danh_Tuan
  final int weekNum;
  final String filePath;

  SubmitReportEvent({
    required this.studentId,
    required this.studentName,
    required this.weekNum,
    required this.filePath,
  });
}

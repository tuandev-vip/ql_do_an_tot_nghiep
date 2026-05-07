class WeeklyReportModel {
  final int week;
  final int? reportId;
  final String status;
  final String deadline;
  final String submitTime;
  final String fileName;
  final String feedback;
  WeeklyReportModel({
    required this.week,
    required this.status,
    required this.deadline,
    this.submitTime = "",
    this.fileName = "",
    this.feedback = "",
    this.reportId,
  });
}

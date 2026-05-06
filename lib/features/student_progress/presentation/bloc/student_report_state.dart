import '../../data/models/weekly_report_model.dart';

abstract class StudentReportState {}

class ReportInitial extends StudentReportState {}

class ReportLoading extends StudentReportState {}

class ReportLoaded extends StudentReportState {
  final Map<int, WeeklyReportModel> reports;
  final int selectedWeek;
  final bool hasActiveBatch;

  ReportLoaded({
    required this.reports,
    required this.selectedWeek,
    this.hasActiveBatch = true,
  });
}

class ReportError extends StudentReportState {
  final String message;
  ReportError(this.message);
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/weekly_report_model.dart';
import '../bloc/student_report_bloc.dart';
import '../bloc/student_report_event.dart';
import '../bloc/student_report_state.dart';
import 'report_detail_card.dart';

class StudentReportTab extends StatefulWidget {
  final String studentId;
  final String studentName;
  const StudentReportTab({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentReportTab> createState() => _StudentReportTabState();
}

class _StudentReportTabState extends State<StudentReportTab> {
  @override
  void initState() {
    super.initState();
    // Vừa vào Tab là bắn Event đòi load dữ liệu luôn
    context.read<StudentReportBloc>().add(LoadReportsEvent(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentReportBloc, StudentReportState>(
      builder: (context, state) {
        if (state is ReportLoading || state is ReportInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReportError) {
          if (state.message.contains("NO_BATCH")) {
            return const Center(
              child: Text(
                "Hiện tại chưa có đợt đồ án nào đang diễn ra.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          } else if (state.message.contains("NO_OUTLINE")) {
            return const Center(
              child: Text(
                "Chưa được báo cáo do giảng viên chưa cập nhật đề cương.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          // Lỗi mạng hoặc lỗi khác thì hiện màu đỏ như cũ
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is ReportLoaded) {
          if (!state.hasActiveBatch) {
            return const Center(
              child: Text(
                "Hiện tại chưa có đợt đồ án nào đang diễn ra.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          final currentReportData = state.reports[state.selectedWeek]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COMPONENT THANH CHỌN TUẦN
              WeekSelectorDropdown(
                selectedWeek: state.selectedWeek,
                reportsData: state.reports,
                onWeekChanged: (newWeek) {
                  context.read<StudentReportBloc>().add(
                    SelectWeekEvent(newWeek!),
                  );
                },
              ),
              const SizedBox(height: 16),
              // COMPONENT THẺ HIỂN THỊ
              Expanded(
                child: SingleChildScrollView(
                  child: ReportDetailCard(
                    week: state.selectedWeek,
                    reportModel: currentReportData,
                    studentId: widget.studentId,
                    studentName: widget.studentName,
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}

// =====================================================================
// COMPONENT 1: THANH DROPDOWN CHỌN TUẦN (ĐÃ NÂNG CẤP DÙNG MODEL)
// =====================================================================
class WeekSelectorDropdown extends StatelessWidget {
  final int selectedWeek;
  final Map<int, WeeklyReportModel> reportsData;
  final ValueChanged<int?> onWeekChanged;

  const WeekSelectorDropdown({
    super.key,
    required this.selectedWeek,
    required this.reportsData,
    required this.onWeekChanged,
  });

  Color _getColorByStatus(String status) {
    switch (status) {
      case "REVIEWED":
        return const Color(0xFF4CAF50);
      case "SUBMITTED":
        return const Color(0xFFFF9800);
      case "OPEN":
        return const Color(0xFF2962FF);
      case "OVERDUE":
        return Colors.redAccent;
      default:
        return Colors.grey.shade400;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "REVIEWED":
        return "Đã nhận xét";
      case "SUBMITTED":
        return "Chờ nhận xét";
      case "OPEN":
        return "Đang mở";
      case "OVERDUE":
        return "Quá hạn nộp";
      default:
        return "Chưa mở";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = reportsData[selectedWeek]!.status;
    final currentColor = _getColorByStatus(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: currentColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: currentColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedWeek,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.white,
          itemHeight: 56,
          onChanged: onWeekChanged,
          items: reportsData.keys.map((weekNum) {
            final status = reportsData[weekNum]!.status;
            final statusText = _getStatusText(status);
            final itemColor = _getColorByStatus(status);

            return DropdownMenuItem<int>(
              value: weekNum,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: itemColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Tuần $weekNum: $statusText",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return reportsData.keys.map((weekNum) {
              final statusText = _getStatusText(reportsData[weekNum]!.status);
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tuần $weekNum: $statusText",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

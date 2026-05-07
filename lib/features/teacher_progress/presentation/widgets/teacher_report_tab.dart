import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import Bloc và Event/State từ bên module Sinh viên vì ta tái sử dụng logic lấy dữ liệu
import '../../../student_progress/presentation/bloc/student_report_bloc.dart';
import '../../../student_progress/presentation/bloc/student_report_event.dart';
import '../../../student_progress/presentation/bloc/student_report_state.dart';

// Import cái Dropdown dùng chung
import '../../../student_progress/presentation/widgets/week_selector_dropdown.dart';

// Import cái Card dành riêng cho Giảng viên mà ông vừa tạo ở trên
import 'teacher_report_detail_card.dart';

class TeacherReportTab extends StatefulWidget {
  final String studentId;

  const TeacherReportTab({super.key, required this.studentId});

  @override
  State<TeacherReportTab> createState() => _TeacherReportTabState();
}

class _TeacherReportTabState extends State<TeacherReportTab> {
  @override
  void initState() {
    super.initState();
    // Vừa mở Tab lên là gọi BLoC để tải dữ liệu báo cáo của đúng sinh viên đó
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
              // TÁI SỬ DỤNG COMPONENT CHỌN TUẦN TỪ BÊN SINH VIÊN
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

              // GỌI THẺ BÁO CÁO CỦA GIẢNG VIÊN VÀO ĐÂY
              Expanded(
                child: SingleChildScrollView(
                  child: TeacherReportDetailCard(
                    week: state.selectedWeek,
                    reportModel: currentReportData,
                    studentId: widget.studentId,
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

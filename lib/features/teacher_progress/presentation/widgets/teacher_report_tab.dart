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
          final msg = state.message.toLowerCase();

          // 💡 1. TRƯỜNG HỢP CHƯA CÓ ĐỀ CƯƠNG (Phổ biến nhất khi mới duyệt SV)
          if (msg.contains("no_outline") ||
              msg.contains("chưa cập nhật đề cương")) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 70,
                    color: Colors.orange.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Vui lòng cập nhật đề cương cho sinh viên này để xem tiến độ!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          // 💡 2. TRƯỜNG HỢP SINH VIÊN CHƯA NỘP GÌ (Dữ liệu trống)
          else if (msg.contains("không tìm thấy") ||
              msg.contains("chưa nộp") ||
              msg.contains("đình chỉ")) {
            // Lưu ý: Chỗ này mình chặn luôn cái chữ "đình chỉ" ảo do PHP trả về sai
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Vui lòng cập nhật đề cương cho sinh viên này để xem tiến độ!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 3. CÁC LỖI KHÁC (Lỗi mạng, server sập...) thì hiện màu đỏ để mình còn biết mà sửa
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Lỗi hệ thống: ${state.message}",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
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

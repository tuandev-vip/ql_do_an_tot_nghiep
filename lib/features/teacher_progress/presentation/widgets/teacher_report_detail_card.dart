import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../student_progress/data/models/weekly_report_model.dart';
import '../../../student_progress/data/repositories/student_report_repository.dart';
import '../../../student_progress/presentation/bloc/student_report_bloc.dart';
import '../../../student_progress/presentation/bloc/student_report_event.dart';

class TeacherReportDetailCard extends StatefulWidget {
  final int week;
  final WeeklyReportModel reportModel;
  final String studentId;

  const TeacherReportDetailCard({
    super.key,
    required this.week,
    required this.reportModel,
    required this.studentId,
  });

  @override
  State<TeacherReportDetailCard> createState() =>
      _TeacherReportDetailCardState();
}

class _TeacherReportDetailCardState extends State<TeacherReportDetailCard> {
  late TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    // Hiển thị lại nhận xét cũ nếu đã từng nhận xét
    _feedbackController = TextEditingController(
      text: widget.reportModel.feedback,
    );
  }

  @override
  void didUpdateWidget(covariant TeacherReportDetailCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật lại nội dung ô text nếu người dùng chuyển tuần khác
    if (oldWidget.reportModel.feedback != widget.reportModel.feedback) {
      _feedbackController.text = widget.reportModel.feedback;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // Hàm xử lý gửi nhận xét
  Future<void> _submitFeedback() async {
    if (widget.reportModel.reportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi: Không tìm thấy ID báo cáo!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hiện Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final message = await StudentReportRepository().updateTeacherFeedback(
        reportId: widget.reportModel.reportId!,
        feedback: _feedbackController.text,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Tắt Loading

      // Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );

      // Bắn Event để Bloc load lại data, giao diện sẽ tự cập nhật thành Đã nhận xét
      context.read<StudentReportBloc>().add(LoadReportsEvent(widget.studentId));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Tắt Loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Hàm mở file báo cáo để Giảng viên xem
  Future<void> _openFile(String fileName) async {
    if (fileName.isEmpty) return;

    // Giả sử đường dẫn lưu file trên server của ông là uploads/reports/
    String rawPath = "uploads/reports/$fileName";
    String base = AppUrls.baseUrl.endsWith('/')
        ? AppUrls.baseUrl.substring(0, AppUrls.baseUrl.length - 1)
        : AppUrls.baseUrl;

    String cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
    String fullUrl = "$base/$cleanPath";

    final Uri url = Uri.parse(Uri.encodeFull(fullUrl));
    try {
      await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi hiển thị: $e")));
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileContainer(String fileName) {
    return InkWell(
      onTap: () => _openFile(fileName), // Click để xem file
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD6E4FF)),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF2962FF),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.reportModel;
    final bool hasFile = report.fileName.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Hạn nộp:", report.deadline),
          _buildInfoRow(
            "SV nộp:",
            report.submitTime.isEmpty ? "Chưa nộp" : report.submitTime,
          ),
          const SizedBox(height: 12),

          if (!hasFile) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  "Sinh viên chưa nộp báo cáo cho tuần này.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text(
              "Tài liệu báo cáo (Nhấn để xem)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _buildFileContainer(report.fileName),

            const SizedBox(height: 24),

            const Text(
              "Nhận xét & Đánh giá",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Nhập nội dung nhận xét...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _submitFeedback,
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  "Duyệt & Gửi nhận xét",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

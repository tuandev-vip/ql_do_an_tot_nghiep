import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/weekly_report_model.dart';
import '../../data/repositories/student_report_repository.dart';
import '../bloc/student_report_bloc.dart';
import '../bloc/student_report_event.dart';

class ReportDetailCard extends StatelessWidget {
  final int week;
  final WeeklyReportModel reportModel;
  final String studentId;
  final String studentName;

  const ReportDetailCard({
    super.key,
    required this.week,
    required this.reportModel,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final String status = reportModel.status;

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
          _buildInfoRow("Hạn nộp:", reportModel.deadline),
          const SizedBox(height: 12),
          if (status == "LOCKED")
            const _EmptyState(text: "Báo cáo tuần này chưa được mở.")
          else if (status == "OPEN") ...[
            const _EmptyState(
              text: "Bạn chưa nộp báo cáo cho tuần này.",
              isItalic: true,
            ),
            _buildUploadButton(context, isUpdate: false),
          ] else if (status == "OVERDUE" && reportModel.submitTime.isEmpty)
            const _EmptyState(
              text: "Đã quá hạn, không thể nộp báo cáo!",
              isError: true,
            )
          else ...[
            _buildInfoRow("Đã nộp:", reportModel.submitTime),
            const SizedBox(height: 20),
            const Text(
              "Tài liệu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _buildFileContainer(reportModel.fileName),
            if (status == "SUBMITTED")
              _buildUploadButton(context, isUpdate: true),
            const SizedBox(height: 24),
            const Text(
              "Đánh giá của GVHD",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _buildFeedbackContainer(reportModel.feedback),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFileContainer(String fileName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: Color(0xFF2962FF), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                color: Color(0xFF2962FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackContainer(String feedback) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Text(
        feedback.isEmpty ? "Chưa có nhận xét" : feedback,
        style: TextStyle(
          color: feedback.isEmpty ? Colors.grey : Colors.black87,
          fontStyle: feedback.isEmpty ? FontStyle.italic : FontStyle.normal,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, {required bool isUpdate}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: ElevatedButton.icon(
          onPressed: () => _handleFileUpload(context),
          icon: Icon(
            isUpdate ? Icons.edit : Icons.upload_file,
            color: Colors.white,
            size: 18,
          ),
          label: Text(
            isUpdate ? "Cập nhật báo cáo" : "Tải lên báo cáo",
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2962FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleFileUpload(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;

      // Bật Loading Dialog và lấy đúng cái context của Dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        final message = await StudentReportRepository().uploadReport(
          studentId: studentId,
          studentName: studentName,
          weekNum: week,
          filePath: filePath,
        );

        // 1. CHỐT CHẶN 1: Bắt buộc phải tắt Dialog bằng rootNavigator trước khi làm việc khác
        Navigator.of(context, rootNavigator: true).pop();

        // 2. Hiện thông báo thành công và Load lại data
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        context.read<StudentReportBloc>().add(LoadReportsEvent(studentId));
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();

        // 2. Quăng lỗi thẳng ra màn hình
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(
              seconds: 5,
            ), // Hiện 5 giây để ông kịp đọc lỗi
          ),
        );
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  final bool isItalic;
  final bool isError;
  const _EmptyState({
    required this.text,
    this.isItalic = false,
    this.isError = false,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Text(
          text,
          style: TextStyle(
            color: isError ? Colors.red : Colors.grey,
            fontSize: 16,
            fontWeight: isError ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

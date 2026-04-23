import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/data/models/teacher_model.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';

class RegistrationDialog extends StatelessWidget {
  final TeacherModel teacher;
  final String studentId;
  final TextEditingController topicController = TextEditingController();

  RegistrationDialog({
    super.key,
    required this.teacher,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Đăng ký: ${teacher.fullName}",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hướng đề tài mong muốn:", style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: topicController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Ví dụ: Phát triển ứng dụng quản lý...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            // 1. KIỂM TRA TRỐNG: Nếu không nhập gì thì báo lỗi ngay tại Dialog
            if (topicController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Vui lòng nhập hướng đề tài mong muốn!"),
                  backgroundColor: Colors.orange,
                ),
              );
              return; // Dừng lại, không gửi lên Bloc và không đóng Dialog
            }

            // 2. Nếu đã nhập nội dung: Gửi sự kiện như bình thường
            context.read<RegistrationBloc>().add(
              SubmitRegistrationEvent(
                teacher.id,
                topicController.text,
                studentId,
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text("Xác nhận"),
        ),
      ],
    );
  }
}

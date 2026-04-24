import 'package:flutter/material.dart';

class SupervisedStudentCard extends StatelessWidget {
  final dynamic student;

  const SupervisedStudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Đổi sang viền xanh lá nhẹ nhàng để báo hiệu trạng thái "Đã duyệt"
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                student['full_name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // Thêm cái tag "Đang hướng dẫn" cho chuyên nghiệp
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Đang hướng dẫn",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoItem(
                Icons.badge_outlined,
                "Mã SV: ${student['student_code']}",
              ),
              const SizedBox(width: 20),
              _infoItem(
                Icons.class_outlined,
                "Lớp: ${student['class_name'] ?? "KTPM K21"}",
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoItem(Icons.email_outlined, "Email: ${student['email']}"),
          const SizedBox(height: 8),
          const Text(
            "Hướng đề tài:",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            student['topic_direction'] ?? "Chưa xác định",
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}

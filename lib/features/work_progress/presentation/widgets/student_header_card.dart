import 'package:flutter/material.dart';

class StudentHeaderCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentHeaderCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy dữ liệu đề tài, kiểm tra xem có bị null hay rỗng không
    String topic = student['topic']?.toString().trim() ?? "";
    bool hasTopic = topic.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 1.5),
                ),
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['student_name'] ?? "Tên sinh viên",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student['student_code'] ?? "Mã SV",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // 2. LOGIC HIỂN THỊ ĐỀ TÀI CHUẨN Ở ĐÂY NÈ
          Text(
            hasTopic ? topic : "Chưa có",
            style: TextStyle(
              fontSize: 14,
              color: hasTopic ? Colors.black87 : Colors.grey.shade600,
              fontStyle: hasTopic
                  ? FontStyle.normal
                  : FontStyle.italic, // Chưa có thì in nghiêng
            ),
          ),
        ],
      ),
    );
  }
}

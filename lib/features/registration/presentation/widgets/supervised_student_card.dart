import 'package:flutter/material.dart';

class SupervisedStudentCard extends StatelessWidget {
  final dynamic student;

  const SupervisedStudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    // 💡 Tự động tìm key đúng
    final studentCode =
        student['student_code']?.toString() ??
        student['student_id']?.toString() ??
        student['id']?.toString() ??
        'Chưa cập nhật';
    final className = student['class_name']?.toString() ?? 'Chưa cập nhật';
    final email = student['email']?.toString() ?? 'Chưa cập nhật';
    final phone =
        student['phone']?.toString() ??
        student['phone_number']?.toString() ??
        'Chưa cập nhật';

    // 🚨 LẤY TRẠNG THÁI TỪ API ĐỂ QUYẾT ĐỊNH MÀU SẮC
    final status = student['status']?.toString() ?? '';
    final isStopped = status == 'STOPPED';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // 💡 ĐỔI MÀU VIÊN: Đỏ nếu bị đình chỉ, Xanh nếu đang hướng dẫn
        border: Border.all(
          color: isStopped ? Colors.red.shade200 : Colors.green.shade100,
          width: 1.5,
        ),
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
              Expanded(
                child: Text(
                  student['full_name'] ?? 'Tên sinh viên',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // 💡 ĐỔI GIAO DIỆN TAG THEO TRẠNG THÁI
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isStopped ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isStopped ? "Đã đình chỉ" : "Đang hướng dẫn",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isStopped
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          _infoItem(Icons.badge_outlined, "Mã SV", studentCode),
          const SizedBox(height: 10),
          _infoItem(Icons.class_outlined, "Lớp", className),
          const SizedBox(height: 10),
          _infoItem(Icons.email_outlined, "Email", email),
          const SizedBox(height: 10),
          _infoItem(Icons.phone_outlined, "Phone", phone),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

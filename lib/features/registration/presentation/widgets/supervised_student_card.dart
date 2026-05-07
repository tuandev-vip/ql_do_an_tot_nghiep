import 'package:flutter/material.dart';

class SupervisedStudentCard extends StatelessWidget {
  final dynamic student;

  const SupervisedStudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    // 💡 XỬ LÝ NULL VÀ SAI KEY Ở ĐÂY:
    // Tự động tìm key đúng, nếu mảng JSON từ PHP trả về tên khác thì ông thêm vào đây
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

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: Color(0xFFEEEEEE),
            ), // Thêm gạch ngang cho đẹp
          ),

          _infoItem(Icons.badge_outlined, "Mã SV", studentCode),
          const SizedBox(height: 10),
          _infoItem(Icons.class_outlined, "Lớp", className),
          const SizedBox(height: 10),
          _infoItem(Icons.email_outlined, "Email", email),
          const SizedBox(height: 10),
          _infoItem(
            Icons.phone_outlined,
            "Phone",
            phone,
          ), // Đã thêm số điện thoại
        ],
      ),
    );
  }

  // 💡 HÀM NÀY ĐÃ ĐƯỢC SỬA LẠI ĐỂ CĂN HAI BÊN
  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Đẩy 2 phần tử ra 2 mép
      children: [
        // Cụm Icon + Nhãn (bên trái)
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
        // Giá trị (bên phải)
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right, // Ép text căn phải
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Nếu dài quá thì hiện "..."
          ),
        ),
      ],
    );
  }
}

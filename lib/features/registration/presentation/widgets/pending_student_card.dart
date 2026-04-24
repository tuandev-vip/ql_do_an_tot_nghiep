import 'package:flutter/material.dart';

class PendingStudentCard extends StatelessWidget {
  final dynamic student;
  final Function(String regId, String status) onAction;

  const PendingStudentCard({
    super.key,
    required this.student,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // PHẦN THÔNG TIN CHI TIẾT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Tên sinh viên", student['full_name'] ?? "N/A"),
                _buildInfoRow("Email", student['email'] ?? "N/A"),
                _buildInfoRow("Lớp", student['class_name'] ?? "N/A"),
                _buildInfoRow("Mã sinh viên", student['username'] ?? "N/A"),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hướng đề tài",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        student['topic_direction'] ?? "Chưa nhập",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PHẦN NÚT BẤM (Dính liền đáy Card)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onAction(student['reg_id'], 'REJECTED'),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Từ chối",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => onAction(student['reg_id'], 'APPROVED'),
                    child: Container(
                      padding: EdgeInsets.only(right: 6),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Đồng ý",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper tạo hàng thông tin: Title sát trái - Dữ liệu sát phải
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Đẩy 2 đầu ra sát lề
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 10), // Khoảng cách an toàn ở giữa
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, // Căn dữ liệu sang phải
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis, // Nếu dài quá thì hiện dấu ...
            ),
          ),
        ],
      ),
    );
  }
}

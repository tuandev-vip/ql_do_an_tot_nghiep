import 'package:flutter/material.dart';

class EvaluationStudentCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const EvaluationStudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sinh viên
                _buildRowInfo(
                  label: "Tên sinh viên",
                  value: student['student_name'],
                  isLabelBold: true,
                  valueColor: Colors.black,
                  valueFontSize: 15,
                ),
                const SizedBox(height: 6),

                // Mã sinh viên
                _buildRowInfo(
                  label: "Mã sinh viên",
                  value: student['student_code'],
                  isLabelBold: true,
                  valueColor: Colors.grey.shade600,
                ),

                const SizedBox(height: 8),

                // Tiến độ
                _buildRowInfo(
                  label: "Tiến độ",
                  value: "${student['progress']}/${student['total_progress']}",
                ),
                const SizedBox(height: 16),

                // Nút Xem tiến độ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Xử lý chuyển sang màn hình chi tiết tiến độ
                      print(
                        "Chuyển sang chi tiết của: ${student['student_name']}",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF4CAF50,
                      ), // Màu xanh lá chuẩn
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Xem tiến độ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dấu chấm đỏ (Notification Indicator) ở góc trên bên phải
        ],
      ),
    );
  }

  // Hàm hỗ trợ vẽ các dòng Text đối xứng 2 bên
  Widget _buildRowInfo({
    required String label,
    required String value,
    bool isLabelBold = false,
    Color? valueColor,
    FontStyle? valueStyle,
    double valueFontSize = 14,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isLabelBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontStyle: valueStyle ?? FontStyle.normal,
              fontSize: valueFontSize,
              fontWeight: isLabelBold && valueFontSize > 14
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

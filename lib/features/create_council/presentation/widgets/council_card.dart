import 'package:flutter/material.dart';

class CouncilCard extends StatelessWidget {
  final String councilName;
  final String councilCode;
  final int studentCount;
  final String memberCountText;
  final String councilType;
  final bool showAssignButton;

  const CouncilCard({
    super.key,
    required this.councilName,
    required this.councilCode,
    required this.studentCount,
    required this.memberCountText,
    required this.councilType,
    this.showAssignButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header màu xanh
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2962FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              councilName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Body thông tin
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildRowInfo("Mã hội đồng :", councilCode),
                const SizedBox(height: 12),
                _buildRowInfo("Số lượng sinh viên", studentCount.toString()),
                const SizedBox(height: 12),
                _buildRowInfo("Thành viên", memberCountText),
                const SizedBox(height: 12),
                _buildRowInfo("Hội đồng :", councilType),

                // Nút Phân bộ môn (chỉ hiện cho HĐ Tổng hợp)
                if (showAssignButton) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2962FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Phân bộ môn",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

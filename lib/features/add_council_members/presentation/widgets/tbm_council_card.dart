import 'package:flutter/material.dart';

class TbmCouncilCard extends StatelessWidget {
  final String councilName;
  final String councilCode;
  final int studentCount;
  final int assignedCount;
  final int quota;
  final String topicDirection;
  final bool isTimeValid; // 💡 Biến kiểm tra còn hạn phân GV không
  final VoidCallback onProposePressed;

  const TbmCouncilCard({
    super.key,
    required this.councilName,
    required this.councilCode,
    required this.studentCount,
    required this.assignedCount,
    required this.quota,
    required this.topicDirection,
    this.isTimeValid = true,
    required this.onProposePressed,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Logic hiển thị chữ "Chưa có" hoặc "1/3"
    String memberDisplay = assignedCount == 0
        ? "Chưa có"
        : "$assignedCount/$quota";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
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
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
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
                _buildRowInfo("Số lượng SV :", studentCount.toString()),
                const SizedBox(height: 12),
                _buildRowInfo("Thành viên :", memberDisplay),
                const SizedBox(height: 12),
                _buildRowInfo("Hướng :", topicDirection),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    // Luôn luôn nhận sự kiện để còn bắn ra SnackBar thông báo.
                    onPressed: onProposePressed,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTimeValid
                          ? const Color(0xFF2962FF)
                          : Colors.grey,
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      assignedCount == quota ? "Đã chốt" : "Đề xuất thành viên",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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

  Widget _buildRowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

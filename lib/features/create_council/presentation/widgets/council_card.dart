import 'package:flutter/material.dart';

class CouncilCard extends StatelessWidget {
  final String councilName;
  final String councilCode;
  final int studentCount;
  final String memberCountText;
  final String councilType;
  final String topicDirection;
  final bool showAssignButton;
  final VoidCallback? onAssignPressed;
  final bool isTimeValid;
  final bool isAssigned; // 💡 Đã có biến này

  const CouncilCard({
    super.key,
    required this.councilName,
    required this.councilCode,
    required this.studentCount,
    required this.memberCountText,
    required this.councilType,
    required this.topicDirection,
    this.showAssignButton = false,
    this.onAssignPressed,
    this.isTimeValid = true,
    this.isAssigned = false, // 💡 Mặc định là chưa phân
  });

  // Hàm cắt cúp chuỗi hướng đề tài
  String _formatTopicDirection(String direction) {
    if (direction.isEmpty || direction == "Chưa phân loại")
      return "Chưa xác định";

    if (direction == "Tổng hợp nhiều hướng") return "Hỗn hợp nhiều hướng";

    List<String> topics = direction
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (topics.length <= 3) {
      return topics.join(', ');
    }

    String firstThree = topics.take(3).join(', ');
    int remaining = topics.length - 3;
    return "$firstThree... (+$remaining hướng)";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
                _buildRowInfo("Số lượng SV :", studentCount.toString()),
                const SizedBox(height: 12),
                _buildRowInfo("Thành viên :", memberCountText),
                const SizedBox(height: 12),
                _buildRowInfo("Hướng :", _formatTopicDirection(topicDirection)),

                // Nút Phân bộ môn (chỉ hiện cho HĐ Tổng hợp)
                if (showAssignButton) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      // 💡 SỬA Ở ĐÂY 1: Nếu đã phân (isAssigned = true) thì gán null để khóa nút
                      onPressed: isAssigned ? null : onAssignPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTimeValid
                            ? const Color(0xFF2962FF)
                            : Colors.grey,
                        // 💡 SỬA Ở ĐÂY 2: Cài đặt màu Xám và chữ trắng khi nút bị khóa
                        disabledBackgroundColor: Colors.grey.shade400,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        // 💡 SỬA Ở ĐÂY 3: Tự động đổi chữ dựa vào trạng thái
                        isAssigned ? "Đã phân" : "Phân bộ môn",
                        style: const TextStyle(color: Colors.white),
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

  // Hàm RowInfo
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

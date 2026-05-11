import 'package:flutter/material.dart';

class CouncilCard extends StatelessWidget {
  final String councilName;
  final String councilCode;
  final int studentCount;
  final String memberCountText;
  final String councilType;
  final String topicDirection; // 💡 Thêm biến này để nhận danh sách Hướng
  final bool showAssignButton;

  const CouncilCard({
    super.key,
    required this.councilName,
    required this.councilCode,
    required this.studentCount,
    required this.memberCountText,
    required this.councilType,
    required this.topicDirection, // 💡 Bắt buộc truyền vào
    this.showAssignButton = false,
  });

  // 💡 Hàm "Ma thuật" cắt cúp chuỗi hướng đề tài
  String _formatTopicDirection(String direction) {
    if (direction.isEmpty || direction == "Chưa phân loại")
      return "Chưa xác định";

    // Đề phòng trường hợp API trả về chuỗi cứng cũ
    if (direction == "Tổng hợp nhiều hướng") return "Hỗn hợp nhiều hướng";

    // Tách chuỗi bằng dấu phẩy và làm sạch khoảng trắng
    List<String> topics = direction
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Nếu có 3 hướng trở xuống -> Cho hiện hết
    if (topics.length <= 3) {
      return topics.join(', ');
    }

    // Nếu nhiều hơn 3 hướng -> Cắt lấy 3 thằng đầu + đếm phần dư
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

                // 💡 Hiển thị Loại Hội đồng và Hướng theo quy tắc mới
                _buildRowInfo("Hướng :", _formatTopicDirection(topicDirection)),

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

  // 💡 Nâng cấp hàm RowInfo để chống lỗi tràn chữ (Overflow)
  Widget _buildRowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // Ép chữ căn sát lên trên
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        // 💡 Expanded giúp chữ tự xuống dòng hoặc bị cắt đẹp mắt nếu quá dài
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            maxLines: 2, // Tối đa 2 dòng
            overflow: TextOverflow.ellipsis, // Quá 2 dòng thì hiện ...
          ),
        ),
      ],
    );
  }
}

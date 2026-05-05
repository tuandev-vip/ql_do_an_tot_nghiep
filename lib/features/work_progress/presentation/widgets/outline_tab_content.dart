import 'package:flutter/material.dart';

class OutlineTabContent extends StatefulWidget {
  const OutlineTabContent({super.key});

  @override
  State<OutlineTabContent> createState() => _OutlineTabContentState();
}

class _OutlineTabContentState extends State<OutlineTabContent> {
  bool isEditing = false;
  String? direction;
  String? topicName;
  String? fileName;

  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _topicNameController = TextEditingController();

  @override
  void dispose() {
    _directionController.dispose();
    _topicNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TRẠNG THÁI 1: CHẾ ĐỘ CHỈNH SỬA
          if (isEditing) ...[
            _buildEditField(
              "Hướng đề tài",
              "Nhập hướng đề tài",
              _directionController,
            ),
            const SizedBox(height: 16),
            _buildEditField(
              "Tên đề tài",
              "Nhập tên đề tài",
              _topicNameController,
            ),
            const SizedBox(height: 16),
            const Text(
              "Đề cương",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                print("Mở file picker...");
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tải tệp lên",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    Icon(
                      Icons.drive_folder_upload,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ]
          // TRẠNG THÁI 2 & 3: CHẾ ĐỘ XEM
          else ...[
            _buildViewField("Hướng đề tài", direction),
            const SizedBox(height: 16),
            _buildViewField("Tên đề tài", topicName),
            const SizedBox(height: 16),
            const Text(
              "Đề cương",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (fileName == null)
              const Text(
                "Chưa có",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "2.4 MB",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 24),

          // NÚT LƯU / CẬP NHẬT
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isEditing) {
                    direction = _directionController.text;
                    topicName = _topicNameController.text;
                    fileName = "DTC2154802010128_Hà Thế Đạt.pdf";
                    isEditing = false;
                  } else {
                    _directionController.text = direction ?? "";
                    _topicNameController.text = topicName ?? "";
                    isEditing = true;
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                isEditing ? "Lưu" : "Cập nhật",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewField(String label, String? value) {
    bool hasValue = value != null && value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          hasValue ? value : "Chưa có",
          style: TextStyle(
            fontSize: 14,
            fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

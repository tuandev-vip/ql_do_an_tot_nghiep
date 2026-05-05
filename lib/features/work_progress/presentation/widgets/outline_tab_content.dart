import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Quan trọng để nhận diện nền tảng

import '../bloc/project_outline_bloc.dart';
import '../bloc/project_outline_event.dart';
import '../bloc/project_outline_state.dart';

class OutlineTabContent extends StatefulWidget {
  final String studentId;
  final Function(String)? onTopicUpdated;
  const OutlineTabContent({
    super.key,
    required this.studentId,
    this.onTopicUpdated,
  });

  @override
  State<OutlineTabContent> createState() => _OutlineTabContentState();
}

class _OutlineTabContentState extends State<OutlineTabContent> {
  bool isEditing = false;
  String? direction;
  String? topicName;
  String? fileName; // Tên file từ database trả về

  // Biến lưu trữ file vừa chọn từ thiết bị
  String? selectedFilePath; // Dùng cho Android
  List<int>? selectedFileBytes; // Dùng cho Web
  String? selectedFileName; // Dùng chung

  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _topicNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Vừa vào Tab là gọi API lấy dữ liệu liền
    context.read<ProjectOutlineBloc>().add(
      FetchProjectOutline(widget.studentId),
    );
  }

  @override
  void dispose() {
    _directionController.dispose();
    _topicNameController.dispose();
    super.dispose();
  }

  // HÀM MỞ FILE PICKER (Phiên bản Lai - Hybrid)
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData:
          kIsWeb, // TỰ ĐỘNG: Web thì lấy Data Byte, Android thì bỏ qua để tránh tràn RAM
    );

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;

        // TỰ ĐỘNG CHIA NHÁNH LƯU DỮ LIỆU FILE
        if (kIsWeb) {
          selectedFileBytes = result.files.single.bytes;
        } else {
          selectedFilePath = result.files.single.path;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectOutlineBloc, ProjectOutlineState>(
      listener: (context, state) {
        if (state is OutlineLoaded) {
          direction = state.outline.topicDirection.isNotEmpty
              ? state.outline.topicDirection
              : null;
          topicName = state.outline.topicName.isNotEmpty
              ? state.outline.topicName
              : null;
          fileName = state.outline.outlineUrl.isNotEmpty
              ? state.outline.outlineUrl
              : null;

          _directionController.text = state.outline.topicDirection;
          _topicNameController.text = state.outline.topicName;
          if (widget.onTopicUpdated != null) {
            widget.onTopicUpdated!(state.outline.topicName);
          }
        }
        // Bắt trạng thái Thành công
        else if (state is OutlineUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Thoát chế độ sửa và dọn dẹp file tạm
          setState(() {
            isEditing = false;
            selectedFilePath = null;
            selectedFileBytes = null;
            selectedFileName = null;
          });
          // Tải lại dữ liệu mới nhất
          context.read<ProjectOutlineBloc>().add(
            FetchProjectOutline(widget.studentId),
          );
        }
        // Bắt trạng thái Thất bại
        else if (state is OutlineUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is OutlineLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  onTap: _pickFile, // Gọi hàm chọn file
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueAccent, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selectedFileName ?? "Nhấn để tải tệp lên (PDF/Doc)",
                            style: TextStyle(
                              color: selectedFileName != null
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                              fontWeight: selectedFileName != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.drive_folder_upload,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
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
                                fileName!.split('/').last,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 24),

              // NÚT CHUYỂN ĐỔI: SỬA HOẶC LƯU
              Align(
                alignment: Alignment.centerRight,
                child: state is OutlineUpdating
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (isEditing) {
                            // BẤM LƯU: Gửi cả 2 biến, BLoC sẽ tự biết lấy cái nào
                            context.read<ProjectOutlineBloc>().add(
                              UpdateProjectOutline(
                                studentId: widget.studentId,
                                topicDirection: _directionController.text,
                                topicName: _topicNameController.text,
                                filePath: selectedFilePath, // Biến của Android
                                fileBytes: selectedFileBytes, // Biến của Web
                                fileName: selectedFileName,
                              ),
                            );
                          } else {
                            // BẤM CẬP NHẬT: Mở chế độ chỉnh sửa
                            setState(() {
                              _directionController.text = direction ?? "";
                              _topicNameController.text = topicName ?? "";
                              selectedFilePath = null;
                              selectedFileBytes = null;
                              selectedFileName = null;
                              isEditing = true;
                            });
                          }
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
      },
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

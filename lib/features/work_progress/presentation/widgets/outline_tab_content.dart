import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../bloc/project_outline_bloc.dart';
import '../bloc/project_outline_event.dart';
import '../bloc/project_outline_state.dart';
import '../../../../core/untils/time_manager.dart';

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
  bool isOverdue = false; // BIẾN LƯU TRẠNG THÁI QUÁ HẠN

  String? direction;
  String? topicName;
  String? fileName;

  String? selectedFilePath;
  List<int>? selectedFileBytes;
  String? selectedFileName;

  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _topicNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
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
          // GOM HẾT VÀO SETSTATE ĐỂ GIAO DIỆN VẼ LẠI
          setState(() {
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

            // DÙNG TIMEMANAGER KIỂM TRA QUÁ HẠN
            if (state.outline.deadline != null &&
                state.outline.deadline!.isNotEmpty) {
              String safeDate = state.outline.deadline!.replaceAll(" ", "T");
              DateTime deadlineDate = DateTime.parse(safeDate);

              // Tích hợp TimeManager thần thánh của ông vào đây
              isOverdue = TimeManager.now().isAfter(deadlineDate);
            } else {
              isOverdue = false;
            }
          });

          if (widget.onTopicUpdated != null) {
            widget.onTopicUpdated!(state.outline.topicName);
          }
        } else if (state is OutlineUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            isEditing = false;
            selectedFilePath = null;
            selectedFileBytes = null;
            selectedFileName = null;
          });
          context.read<ProjectOutlineBloc>().add(
            FetchProjectOutline(widget.studentId),
          );
        } else if (state is OutlineUpdateFailure) {
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
                  onTap: _pickFile,
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

              // DÒNG TEXT CẢNH BÁO MÀU ĐỎ KHI HẾT HẠN
              if (isOverdue)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "⏳ Đã hết hạn cập nhật đề cương!",
                      style: TextStyle(
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // NÚT CHUYỂN ĐỔI: SỬA HOẶC LƯU
              Align(
                alignment: Alignment.centerRight,
                child: state is OutlineUpdating
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        // NẾU QUÁ HẠN -> KHÓA NÚT (TRẢ VỀ NULL)
                        onPressed: isOverdue
                            ? null
                            : () {
                                if (isEditing) {
                                  context.read<ProjectOutlineBloc>().add(
                                    UpdateProjectOutline(
                                      studentId: widget.studentId,
                                      topicDirection: _directionController.text,
                                      topicName: _topicNameController.text,
                                      filePath: selectedFilePath,
                                      fileBytes: selectedFileBytes,
                                      fileName: selectedFileName,
                                    ),
                                  );
                                } else {
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
                          // ĐỔI MÀU NỀN THEO TRẠNG THÁI KHÓA/MỞ
                          backgroundColor: isOverdue
                              ? Colors.grey.shade400
                              : const Color(0xFF2962FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Text(
                          isEditing ? "Lưu" : "Cập nhật",
                          style: TextStyle(
                            // ĐỔI MÀU CHỮ
                            color: isOverdue
                                ? Colors.grey.shade600
                                : Colors.white,
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

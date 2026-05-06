import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart'; // Để mở link DOCX

import '../../../../core/constants/app_urls.dart';
import '../../../work_progress/presentation/bloc/project_outline_bloc.dart';
import '../../../work_progress/presentation/bloc/project_outline_event.dart';
import '../../../work_progress/presentation/bloc/project_outline_state.dart';

class StudentOutlineTab extends StatefulWidget {
  final String studentId;

  const StudentOutlineTab({super.key, required this.studentId});

  @override
  State<StudentOutlineTab> createState() => _StudentOutlineTabState();
}

class _StudentOutlineTabState extends State<StudentOutlineTab> {
  @override
  void initState() {
    super.initState();
    // Vẫn mượn tạm BLoC của GVHD để xài vì chung API lấy dữ liệu
    context.read<ProjectOutlineBloc>().add(
      FetchProjectOutline(widget.studentId),
    );
  }

  // HÀM XỬ LÝ CLICK FILE SIÊU TRÍ TUỆ NẰM Ở ĐÂY
  Future<void> _handleOpenFile(String fileUrl) async {
    // Ghép link hoàn chỉnh từ server
    String fullUrl = "${AppUrls.baseUrl}/$fileUrl";
    final Uri url = Uri.parse(fullUrl);

    try {
      // DÙNG LỰC ÉP MỞ LUÔN, KHÔNG THÈM CHECK canLaunchUrl NỮA
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // NẾU LỖI THÌ BÁO RA MÀN HÌNH
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Không thể mở file! Vui lòng cài đặt trình duyệt hoặc app đọc PDF.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectOutlineBloc, ProjectOutlineState>(
      builder: (context, state) {
        if (state is OutlineLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Đóng đợt đồ án thì báo lỗi ở đây
        if (state is OutlineError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is OutlineLoaded) {
          final outline = state.outline;
          String fileName = outline.outlineUrl.isNotEmpty
              ? outline.outlineUrl.split('/').last
              : "";
          String fileExt = fileName.isNotEmpty
              ? fileName.split('.').last.toLowerCase()
              : "";

          // Chọn Icon tùy theo loại file cho ngầu
          IconData fileIcon = Icons.insert_drive_file;
          Color iconColor = Colors.grey;
          if (fileExt == 'pdf') {
            fileIcon = Icons.picture_as_pdf;
            iconColor = Colors.redAccent;
          } else if (fileExt == 'doc' || fileExt == 'docx') {
            fileIcon = Icons.description;
            iconColor = Colors.blueAccent;
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  "Hướng đề tài",
                  outline.topicDirection.isNotEmpty
                      ? outline.topicDirection
                      : "Chưa có",
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  "Tên đề tài",
                  outline.topicName.isNotEmpty ? outline.topicName : "Chưa có",
                ),
                const SizedBox(height: 24),

                const Text(
                  "Đề cương",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                if (outline.outlineUrl.isEmpty)
                  const Text(
                    "Chưa có",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                else
                  InkWell(
                    onTap: () => _handleOpenFile(
                      outline.outlineUrl,
                    ), // GỌI HÀM XỬ LÝ Ở ĐÂY
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            fileIcon,
                            color: iconColor,
                            size: 36,
                          ), // Icon động theo đuôi file
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fileName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              Icons.open_in_new, // Icon nút nhỏ cũng đổi theo
                              color: Colors.black54,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: value == "Chưa có" ? Colors.grey : Colors.black87,
            fontStyle: value == "Chưa có" ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

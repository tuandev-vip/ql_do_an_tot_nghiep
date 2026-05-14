import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/work_progress/presentation/bloc/project_outline_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/work_progress/presentation/bloc/project_outline_event.dart';
import 'package:ql_do_an_tot_nghiep/features/work_progress/presentation/bloc/project_outline_state.dart';
import 'package:url_launcher/url_launcher.dart';

// Import file cấu hình URL của ông
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';

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
    // Vừa mở Tab lên là gọi lấy dữ liệu Đề Cương từ Server[cite: 4]
    context.read<ProjectOutlineBloc>().add(
      FetchProjectOutline(widget.studentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectOutlineBloc, ProjectOutlineState>(
      builder: (context, state) {
        // Trạng thái đang tải[cite: 9]
        if (state is OutlineLoading || state is OutlineInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        // Trạng thái lỗi[cite: 9]
        if (state is OutlineError) {
          final msg = state.message.toLowerCase();

          // 💡 Xử lý lỗi trống dữ liệu y như bên Tab Báo cáo
          if (msg.contains("đình chỉ") ||
              msg.contains("không tìm thấy") ||
              msg.contains("chưa đăng ký") ||
              msg.contains("không có đợt") ||
              msg.contains("no_batch")) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Chưa có đợt đồ án nào được mở.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Trạng thái đã tải dữ liệu thành công[cite: 9]
        if (state is OutlineLoaded) {
          final outline = state.outline;
          final huongDeTai = outline.topicDirection.isNotEmpty
              ? outline.topicDirection
              : "Chưa cập nhật";
          final tenDeTai = outline.topicName.isNotEmpty
              ? outline.topicName
              : "Chưa cập nhật";

          final fileUrl = outline.outlineUrl;
          final hasFile = fileUrl.isNotEmpty;

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
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoSection("Hướng đề tài", huongDeTai),
                const SizedBox(height: 20),
                _buildInfoSection("Tên đề tài", tenDeTai),
                const SizedBox(height: 20),

                const Text(
                  "Đề cương",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),

                // Nếu có file thì render UI Link PDF, nếu không thì báo chưa có[cite: 13, 20]
                hasFile
                    ? _buildPdfLink(context, fileUrl)
                    : const Text(
                        "Giảng viên chưa cập nhật đề cương.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  // Widget hiển thị thông tin dạng tiêu đề + nội dung[cite: 20]
  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ],
    );
  }

  // Widget hiển thị liên kết file PDF[cite: 13, 17]
  Widget _buildPdfLink(BuildContext context, String fileUrl) {
    final fileName = fileUrl
        .split('/')
        .last; // Cắt URL để lấy tên file hiển thị

    return InkWell(
      onTap: () async {
        String rawPath = fileUrl;
        String base = AppUrls.baseUrl.endsWith('/')
            ? AppUrls.baseUrl.substring(0, AppUrls.baseUrl.length - 1)
            : AppUrls.baseUrl;

        String cleanPath = rawPath.startsWith('/')
            ? rawPath.substring(1)
            : rawPath;
        String fullUrl = "$base/$cleanPath";

        // Mã hóa URL để xử lý tiếng Việt
        final String encodedUrl = Uri.encodeFull(fullUrl);
        final Uri url = Uri.parse(encodedUrl);

        try {
          // THAY ĐỔI: Sử dụng inAppBrowserView thay vì externalApplication
          // Chế độ này thường hiển thị PDF trực tiếp tốt hơn trên Android
          await launchUrl(url, mode: LaunchMode.inAppBrowserView);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Lỗi hiển thị: $e")));
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

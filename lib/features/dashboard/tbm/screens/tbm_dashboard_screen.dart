import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/tbm/bloc/tbm_dashboard_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/tbm/bloc/tbm_dashboard_event.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/tbm/bloc/tbm_dashboard_state.dart';

// ⚠️ SỬA LẠI ĐƯỜNG DẪN IMPORT 3 FILE BLOC NÀY CHO ĐÚNG VỚI MÁY CỦA ÔNG NHÉ

class TbmDashboardScreen extends StatefulWidget {
  final String departmentId;
  const TbmDashboardScreen({super.key, required this.departmentId});

  @override
  State<TbmDashboardScreen> createState() => _TbmDashboardScreenState();
}

class _TbmDashboardScreenState extends State<TbmDashboardScreen> {
  // Bỏ hết mấy biến số liệu giả đi, chỉ giữ lại state của AI thôi
  bool isAILoading = false;
  bool hasAIResult = false;
  int currentWeek = 4; // Tuần hiện tại có thể thay đổi

  @override
  void initState() {
    super.initState();
    // 💡 Vừa mở màn hình lên là gọi BLoC lấy số liệu thật liền!
    context.read<TbmDashboardBloc>().add(
      LoadTbmDashboardStats(widget.departmentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "ICTU",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.business_center,
                  size: 18,
                  color: Color(0xFF2196F3),
                ),
                const SizedBox(width: 6),
                Text(
                  "BỘ MÔN: ${widget.departmentId}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 💡 BLOC BUILDER VẼ CÁC THẺ THỐNG KÊ TỪ DATA THẬT
            BlocBuilder<TbmDashboardBloc, TbmDashboardState>(
              builder: (context, state) {
                if (state is TbmDashboardLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    ),
                  );
                } else if (state is TbmDashboardError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else if (state is TbmDashboardLoaded) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.9,
                    children: [
                      _buildStatCard(
                        "Sinh viên",
                        state.totalStudents.toString(),
                        Icons.school_outlined,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        "Giảng viên",
                        state.totalTeachers.toString(),
                        Icons.person_outline,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        "Chưa có GV",
                        state.noAdvisor.toString(),
                        Icons.error_outline,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        "HĐ thiếu TV",
                        state.missingMembers.toString(),
                        Icons.group_remove_outlined,
                        Colors.red,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink(); // Initial state
              },
            ),

            const SizedBox(height: 16),

            // KHU VỰC AI ĐÃ SỬA LẠI NỀN TRẮNG
            Expanded(child: _buildAIBoard()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isAILoading) return;
          setState(() {
            isAILoading = true;
            hasAIResult = false;
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                isAILoading = false;
                hasAIResult = true;
              });
            }
          });
        },
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          "AI Thống kê",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAIBoard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildAIContent(),
    );
  }

  Widget _buildAIContent() {
    if (isAILoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            "AI đang thống kê tiến độ Tuần $currentWeek...",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    if (hasAIResult) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.blueAccent,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  "Thống kê Tuần $currentWeek",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _buildResultRow(
              Icons.analytics_outlined,
              Colors.blue,
              "Tổng hợp: 85% sinh viên hoàn thành mốc báo cáo.",
            ),
            const SizedBox(height: 12),
            _buildResultRow(
              Icons.bug_report_outlined,
              Colors.orange,
              "Cảnh báo: 3 nhóm đang gặp lỗi cấu hình Database.",
            ),
            const SizedBox(height: 12),
            _buildResultRow(
              Icons.copy_all_outlined,
              Colors.red,
              "Phát hiện nội dung tương đồng cao tại 1 báo cáo.",
            ),
            const SizedBox(height: 20),
            Text(
              "Dữ liệu được trích xuất từ các tệp tin .docx gửi về máy chủ ICTU.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insights_rounded, size: 50, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          "Sẵn sàng phân tích dữ liệu bộ môn",
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildResultRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

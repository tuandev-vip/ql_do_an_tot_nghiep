import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/tbm/bloc/tbm_dashboard_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/tbm/bloc/tbm_dashboard_event.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/tbm/bloc/tbm_dashboard_state.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/screens/notification_screen.dart';

class TbmDashboardScreen extends StatefulWidget {
  final String departmentId;
  const TbmDashboardScreen({super.key, required this.departmentId});

  @override
  State<TbmDashboardScreen> createState() => _TbmDashboardScreenState();
}

class _TbmDashboardScreenState extends State<TbmDashboardScreen> {
  @override
  void initState() {
    super.initState();
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
        // 💡 ĐÃ BỌC BLOCBUILDER Ở ĐÂY ĐỂ FIX LỖI "UNDEFINED NAME STATE"
        actions: [
          BlocBuilder<TbmDashboardBloc, TbmDashboardState>(
            builder: (context, state) {
              bool unread = false;
              // Kiểm tra xem state đã load xong chưa và có biến hasUnread không
              if (state is TbmDashboardLoaded) {
                unread = state.hasUnread;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () async {
                      // Gọi sang màn hình thông báo và chờ nó quay lại
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => NotificationBloc(),
                            child: NotificationScreen(
                              userId: widget.departmentId,
                              role: "TRUONG_BO_MON",
                            ),
                          ),
                        ),
                      );
                      // Quay lại thì tự động refresh Dashboard để mất chấm đỏ
                      if (context.mounted) {
                        context.read<TbmDashboardBloc>().add(
                          LoadTbmDashboardStats(widget.departmentId),
                        );
                      }
                    },
                  ),
                  // CHẤM ĐỎ THÔNG MINH
                  if (unread)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          minHeight: 10,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<TbmDashboardBloc, TbmDashboardState>(
        builder: (context, state) {
          if (state is TbmDashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          } else if (state is TbmDashboardError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is TbmDashboardLoaded) {
            return Padding(
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
                  GridView.count(
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
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildAIBoard(state)),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: BlocBuilder<TbmDashboardBloc, TbmDashboardState>(
        builder: (context, state) {
          bool isDisabled = true;
          bool isLoading = false;

          if (state is TbmDashboardLoaded) {
            isLoading = state.isAILoading;

            // LOGIC CHẶN NÚT AI
            if (state.hasBatch &&
                state.outlineDeadline != null &&
                state.reportW10Deadline != null) {
              DateTime now = TimeManager.now();

              // Nếu Giờ Máy >= Hạn Đề Cương VÀ Giờ Máy <= Hạn Cuối W10
              if (now.compareTo(state.outlineDeadline!) >= 0 &&
                  now.compareTo(state.reportW10Deadline!) <= 0) {
                isDisabled = false;
              }
            }

            isDisabled = isDisabled || isLoading;
          }

          return FloatingActionButton.extended(
            heroTag: null,
            onPressed: isDisabled
                ? null
                : () {
                    context.read<TbmDashboardBloc>().add(
                      GenerateAIStatsEvent(
                        deptId: widget.departmentId,
                        weekNum: 1,
                      ),
                    );
                  },
            backgroundColor: isDisabled ? Colors.grey : const Color(0xFF2196F3),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome, color: Colors.white),
            label: Text(
              isLoading ? "Đang xử lý..." : "AI Thống kê",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAIBoard(TbmDashboardLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: _buildAIContent(state),
    );
  }

  Widget _buildAIContent(TbmDashboardLoaded state) {
    if (!state.hasBatch) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, size: 50, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                "Hiện chưa có Đợt đồ án nào được mở.",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isAILoading) {
      return const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.blueAccent,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                "AI đang phân tích tiến độ hệ thống...",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.aiError != null) {
      return Center(
        child: SingleChildScrollView(
          child: Text(
            state.aiError!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    if (state.aiSummary != null) {
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
                const Text(
                  "Thống kê Tiến độ AI",
                  style: TextStyle(
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
            Text(
              state.aiSummary!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_rounded, size: 50, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              "Nhấn nút bên dưới để phân tích báo cáo",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/student/bloc/student_dashboard_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/student/bloc/student_dashboard_event.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/student/bloc/student_dashboard_state.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/screens/notification_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String studentId;
  const StudentDashboardScreen({super.key, required this.studentId});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentDashboardBloc>().add(
      LoadStudentDashboardStats(widget.studentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "SINH VIÊN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
            builder: (context, state) {
              bool unread = false;
              if (state is StudentDashboardLoaded) unread = state.hasUnread;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => NotificationBloc(),
                            child: NotificationScreen(
                              userId: widget.studentId,
                              role: "SINH_VIEN",
                            ),
                          ),
                        ),
                      );
                      if (context.mounted) {
                        context.read<StudentDashboardBloc>().add(
                          LoadStudentDashboardStats(widget.studentId),
                        );
                      }
                    },
                  ),
                  if (unread)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
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
      body: BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
        builder: (context, state) {
          if (state is StudentDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudentDashboardError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is StudentDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<StudentDashboardBloc>().add(
                  LoadStudentDashboardStats(widget.studentId),
                );
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 💡 THẺ THÔNG TIN ĐỒ ÁN
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "GVHD: ${state.advisorName ?? 'Chưa phân công'}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            "Timeline Tiến Độ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 💡 GIAO DIỆN TIMELINE
                          if (!state.hasBatch)
                            const Center(
                              child: Text("Chưa có đợt đồ án nào đang mở."),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: state.deadlines.entries.map((entry) {
                                  return _buildTimelineTile(
                                    entry.key,
                                    entry.value,
                                  );
                                }).toList(),
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
          return const SizedBox();
        },
      ),
    );
  }

  // 🛠️ HÀM VẼ TỪNG DÒNG TIMELINE
  Widget _buildTimelineTile(String title, DateTime? deadline) {
    if (deadline == null) return const SizedBox();

    DateTime now = TimeManager.now();
    bool isPassed = now.isAfter(
      deadline,
    ); // Nếu giờ hiện tại đã vượt qua deadline
    bool isUrgent =
        now.isBefore(deadline) &&
        deadline.difference(now).inDays <= 2; // Còn <= 2 ngày

    Color dotColor = isPassed
        ? Colors.green
        : (isUrgent ? Colors.orange : Colors.grey.shade300);
    IconData icon = isPassed
        ? Icons.check_circle
        : (isUrgent ? Icons.warning : Icons.circle);

    return IntrinsicHeight(
      child: Row(
        children: [
          // Cột vẽ đường kẻ và dấu chấm
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Icon(icon, color: dotColor, size: 20),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isPassed
                        ? Colors.green.shade200
                        : Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Cột nội dung
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.black87 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hạn chót: ${DateFormat('dd/MM/yyyy HH:mm').format(deadline)}",
                    style: TextStyle(
                      fontSize: 13,
                      color: isUrgent
                          ? Colors.orange.shade700
                          : Colors.grey.shade600,
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
}

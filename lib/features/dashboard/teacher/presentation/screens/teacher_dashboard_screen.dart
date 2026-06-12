import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ql_do_an_tot_nghiep/features/dashboard/teacher/presentation/bloc/teacher_dashboard_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/teacher/presentation/bloc/teacher_dashboard_event.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/teacher/presentation/bloc/teacher_dashboard_state.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/teacher/presentation/widgets/student_dashboard_details.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/teacher/presentation/widgets/total_students_card.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/teacher/presentation/widgets/dashboard_empty_state.dart';

// 💡 NHỚ IMPORT THÊM 2 FILE CỦA NOTIFICATION SCREEN
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/screens/notification_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  final int teacherId;
  const TeacherDashboardScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TeacherDashboardBloc()..add(FetchTeacherDashboard(teacherId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "ICTU",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF2962FF),
          elevation: 0,
          actions: [
            // 💡 BỌC BLOCBUILDER Ở ĐÂY ĐỂ VẼ CHẤM ĐỎ
            BlocBuilder<TeacherDashboardBloc, TeacherDashboardState>(
              builder: (context, state) {
                bool unread = false;
                if (state is DashboardLoaded) {
                  unread = state.hasUnread;
                }

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
                        // 1. Chuyển hướng sang màn thông báo
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => NotificationBloc(),
                              child: NotificationScreen(
                                userId: teacherId
                                    .toString(), // Đổi sang chữ vì NotificationScreen yêu cầu String
                                role: "GIANG_VIEN",
                              ),
                            ),
                          ),
                        );

                        // 2. Quay về thì gọi Load lại để mất chấm đỏ
                        if (context.mounted) {
                          context.read<TeacherDashboardBloc>().add(
                            FetchTeacherDashboard(teacherId),
                          );
                        }
                      },
                    ),
                    // VẼ CHẤM ĐỎ
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
        body: BlocBuilder<TeacherDashboardBloc, TeacherDashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading)
              return const Center(child: CircularProgressIndicator());
            if (state is DashboardError)
              return Center(child: Text(state.message));

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TeacherDashboardBloc>().add(
                    FetchTeacherDashboard(teacherId),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. GỌI WIDGET THẺ TỔNG
                      TotalStudentsCard(total: state.totalStudents),

                      const SizedBox(height: 24),

                      // 2. KHUNG THỐNG KÊ
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Thống kê",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (state.viewStatus == 'NO_BATCH')
                              const DashboardEmptyState(
                                message: "Hiện tại chưa có đợt đồ án.",
                              )
                            else if (state.viewStatus == 'NO_STUDENTS')
                              const DashboardEmptyState(
                                message:
                                    "Hiện tại chưa có sinh viên hướng dẫn.",
                              )
                            else if (state.viewStatus == 'NOT_REPORTING_TIME')
                              const DashboardEmptyState(
                                message:
                                    "Đang trong thời gian làm đề cương.\nChưa đến giai đoạn báo cáo tiến độ.",
                              )
                            else if (state.statistics.isEmpty)
                              const DashboardEmptyState(
                                message:
                                    "Chưa có sinh viên nào bắt đầu báo cáo.",
                              )
                            else
                              // GỌI WIDGET TỪNG SINH VIÊN
                              ...state.statistics.map(
                                (sv) => StudentDashboardTile(studentData: sv),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

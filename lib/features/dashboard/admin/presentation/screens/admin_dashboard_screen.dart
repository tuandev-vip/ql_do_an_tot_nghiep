import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/admin/bloc/admin_dashboard_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/admin/bloc/admin_dashboard_event.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/admin/bloc/admin_dashboard_state.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/screens/notification_screen.dart';
import 'dart:async';
import 'package:ql_do_an_tot_nghiep/features/user/presentation/bloc/user_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/user/presentation/bloc/user_event.dart';
import '../../../../user/presentation/bloc/user_state.dart';
import '../../../../batch/presentation/bloc/batch_bloc.dart';
import '../../../../batch/presentation/bloc/batch_state.dart';
import '../widgets/test_mode_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // 💡 Gắn ăng-ten lắng nghe sự kiện cuộn
    _scrollController.addListener(_onScroll);
    context.read<UserBloc>().add(FetchUsersEvent(isRefresh: true));
    // 💡 Gọi Bloc của Admin để check chấm đỏ
    context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats());
  }

  // 💡 Thuật toán chạm đáy tải thêm
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      final state = context.read<UserBloc>().state;
      if (state is UserLoaded &&
          !state.hasReachedMax &&
          !state.isFetchingMore) {
        context.read<UserBloc>().add(FetchUsersEvent());
      }
    }
  }

  // 💡 Chống spam gõ tìm kiếm
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<UserBloc>().add(SearchUserEvent(query));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        centerTitle: true, // Bật cái này lên để tự động căn giữa chữ tuyệt đối
        title: const Text(
          "ICTU",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
            builder: (context, state) {
              bool unread = false;
              if (state is AdminDashboardLoaded) {
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
                      // Chuyển sang màn hình thông báo
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => NotificationBloc(),
                            child: const NotificationScreen(
                              userId: "ADMIN",
                              role: "ADMIN",
                            ),
                          ),
                        ),
                      );

                      // 💡 Đọc xong quay ra, gọi lại Event để load lại chấm đỏ
                      if (context.mounted) {
                        context.read<AdminDashboardBloc>().add(
                          LoadAdminDashboardStats(),
                        );
                      }
                    },
                  ),
                  // VẼ CHẤM ĐỎ NẾU CÓ THÔNG BÁO MỚI
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
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        // 💡 BỌC REFRESH INDICATOR Ở ĐÂY
        child: RefreshIndicator(
          color: Colors.blueAccent,
          backgroundColor: Colors.white,
          onRefresh: () async {
            // 1. Kéo xuống là gọi API load lại chấm đỏ của Admin
            context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats());
            // 2. Đồng thời load lại danh sách người dùng mới luôn
            context.read<UserBloc>().add(FetchUsersEvent(isRefresh: true));

            // Chờ 1 chút xíu để vòng xoay hiển thị mượt mà
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: CustomScrollView(
            controller: _scrollController,
            // 💡 QUAN TRỌNG: Thêm physics này để danh sách ngắn vẫn vuốt xuống được
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ----------------------------------------------------
              // PHẦN 1: HEADER (Được bọc trong SliverToBoxAdapter)
              // ----------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<BatchBloc, BatchState>(
                        builder: (context, state) {
                          final activeBatch =
                              (state is BatchLoaded && state.batches.isNotEmpty)
                              ? state.batches.firstWhere(
                                  (b) => b.isClosed == 0,
                                  orElse: () => state.batches.first,
                                )
                              : null;
                          return TestModeCard(activeBatch: activeBatch);
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Thống kê người dùng",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          int tCount = 0, sCount = 0;
                          if (state is UserLoaded) {
                            tCount = state.teacherCount;
                            sCount = state.studentCount;
                          }
                          return Row(
                            children: [
                              _buildStatCard(
                                "Giảng viên",
                                "$tCount",
                                Icons.groups_outlined,
                                Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Sinh viên",
                                "$sCount",
                                Icons.school_outlined,
                                Colors.orange,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm mã SV, mã GV hoặc tên...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Danh sách tài khoản",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ----------------------------------------------------
              // PHẦN 2: DANH SÁCH (Được bọc trong SliverList.builder)
              // ----------------------------------------------------
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  } else if (state is UserLoaded) {
                    if (state.users.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              "Không tìm thấy người dùng nào",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverList.builder(
                        itemCount:
                            state.users.length + (state.isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // 💡 Đang cuộn thì hiện xoay xoay ở thẻ cuối cùng
                          if (index >= state.users.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _buildUserAccountCard(
                            context,
                            state.users[index],
                          );
                        },
                      ),
                    );
                  } else if (state is UserError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Các hàm Widget Card giữ nguyên ---
  Widget _buildUserAccountCard(BuildContext context, user) {
    String idLabel = (user.role == 'STUDENT') ? "Mã SV" : "Mã GV";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Chức vụ: ${user.role}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  "$idLabel: ${user.username}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Mật khẩu: ${user.password ?? '123456'}",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _confirmReset(context, user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Khôi phục"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(icon, color: color, size: 28),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận reset"),
        content: Text("Mật khẩu sẽ được đưa về '123456'"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserBloc>().add(ResetPasswordEvent(user.id));
              Navigator.pop(ctx);
            },
            child: const Text("Đồng ý"),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          IconButton(
            icon: const Icon(
              Icons.notifications, // Icon cái chuông
              color: Colors.white,
              size: 28, // Chỉnh nhẹ size cho cân đối với chữ ICTU
            ),
            onPressed: () {},
          ),
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
        // 💡 SỬ DỤNG CUSTOM SCROLL VIEW ĐỂ CUỘN FULL MÀN HÌNH NHƯNG VẪN LAZY LOAD
        child: CustomScrollView(
          controller: _scrollController,
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
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

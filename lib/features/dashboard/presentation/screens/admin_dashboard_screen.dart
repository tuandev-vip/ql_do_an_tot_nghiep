import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/user/presentation/bloc/user_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../batch/presentation/bloc/batch_bloc.dart';
import '../../../batch/presentation/bloc/batch_state.dart';
import '../widgets/test_mode_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: Center(
          child: Text(
            "ICTU",

            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      // Dùng BlocListener để hiện thông báo khi reset mật khẩu thành công
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CỖ MÁY THỜI GIAN (Giữ lại để test đợt)
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
              const SizedBox(height: 20),

              // 2. CARD THỐNG KÊ (Lấy số lượng từ UserBloc)
              const Text(
                "Thống kê người dùng",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  int tCount = 0;
                  int sCount = 0;
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
              const SizedBox(height: 20),

              // 3. THANH TÌM KIẾM (Search theo mã hoặc tên)
              TextField(
                onChanged: (value) {
                  // Gửi event tìm kiếm vào Bloc
                  context.read<UserBloc>().add(SearchUserEvent(value));
                },
                decoration: InputDecoration(
                  hintText: "Tìm kiếm mã SV, mã GV hoặc tên...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. DANH SÁCH TÀI KHOẢN
              const Text(
                "Danh sách tài khoản",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserLoaded) {
                    if (state.users.isEmpty) {
                      return const Center(
                        child: Text("Không tìm thấy người dùng nào"),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return _buildUserAccountCard(context, user);
                      },
                    );
                  } else if (state is UserError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Card User [Hiển thị Tên, Chức vụ, Mã, Mật khẩu]
  Widget _buildUserAccountCard(BuildContext context, user) {
    String idLabel = (user.role == 'STUDENT') ? "Mã SV" : "Mã GV";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
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
                // Hiển thị mật khẩu trực quan
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

  // Widget 2 Card thống kê nhỏ gọn
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

  // Dialog xác nhận reset mật khẩu
  void _confirmReset(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận reset"),
        content: Text(
          "Mật khẩu của ${user.fullName} sẽ được đưa về '123456'. Bạn có chắc chắn?",
        ),
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

import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import 'change_password_screen.dart'; // Đảm bảo bạn đã tạo file này

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  // Xử lý logic Đăng xuất
  void _handleLogout(BuildContext context) {
    // In ra console để kiểm tra xem nút có hoạt động không
    print("User ${user.fullName} is logging out...");

    // Đẩy về màn hình Login và xóa sạch lịch sử các trang trước đó
    // Lưu ý: Bạn phải định nghĩa '/login' trong routes của main.dart
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF2), // Màu nền xám nhạt chuẩn Figma
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          "CÁ NHÂN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // --- PHẦN 1: AVATAR ---
            Center(
              child: Container(
                width: 120,
                height: 120,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            // --- PHẦN 2: DANH SÁCH THÔNG TIN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  _buildInfoRow("Họ và tên", user.fullName),
                  _buildInfoRow(
                    user.role == 'STUDENT' ? "Mã sinh viên" : "Mã giảng viên",
                    user.userCode,
                  ),

                  // Luôn hiển thị Khoa
                  _buildInfoRow("Khoa", user.facultyName),

                  // Chỉ hiện Bộ môn nếu người đó KHÔNG PHẢI là Trưởng khoa
                  if (user.position != 'Trưởng khoa')
                    _buildInfoRow("Bộ môn", user.deptName),

                  _buildInfoRow("SĐT", user.phone),
                  _buildInfoRow("Email", user.email),

                  // Chỉ hiện Lớp nếu là Sinh viên
                  if (user.role == 'STUDENT' && user.className != null)
                    _buildInfoRow("Lớp", user.className!),

                  const SizedBox(height: 40),

                  // --- PHẦN 3: NÚT ĐỔI MẬT KHẨU ---
                  // Sử dụng Material + InkWell để tạo hiệu ứng click (Ripple effect)
                  Material(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {
                        // Chuyển sang file change_password_screen.dart đã tách
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChangePasswordScreen(userId: user.userId),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Cập nhật mật khẩu",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo từng dòng thông tin (Scannable & Clean)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.withOpacity(0.3), thickness: 1),
        ],
      ),
    );
  }
}

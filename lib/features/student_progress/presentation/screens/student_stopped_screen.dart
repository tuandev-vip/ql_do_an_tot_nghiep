import 'package:flutter/material.dart';

class StudentStoppedScreen extends StatelessWidget {
  const StudentStoppedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thông báo hệ thống",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.red.shade700,
        centerTitle: true,
        automaticallyImplyLeading: false, // Chặn nút quay lại của hệ thống
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Xử lý đăng xuất (xóa session/token) và đẩy về màn hình Login
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 100),
              const SizedBox(height: 24),
              const Text(
                "BẠN ĐÃ BỊ ĐÌNH CHỈ\nTHỰC HIỆN ĐỒ ÁN",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: const Text(
                  "Giáo viên hướng dẫn đã chấm điểm quá trình của bạn dưới 4. Theo quy chế, bạn không đủ điều kiện để tiếp tục thực hiện đồ án tốt nghiệp.\n\nMọi thắc mắc vui lòng liên hệ trực tiếp với Giảng viên hướng dẫn của bạn để được giải quyết.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

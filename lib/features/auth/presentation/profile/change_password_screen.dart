import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;
  const ChangePasswordScreen({super.key, required this.userId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _isLoading = false;

  // 1. Hàm hiển thị thông báo (Để riêng ra ngoài cho sạch)
  void showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // 2. Hàm xử lý cập nhật mật khẩu (Gộp lại thành 1 hàm duy nhất)
  Future<void> _updatePassword() async {
    String oldPass = _oldPassController.text.trim();
    String newPass = _newPassController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty) {
      showSnackBar("Vui lòng nhập đầy đủ thông tin", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(AppUrls.urlChangePassword),
        body: {
          "user_id": widget.userId.toString(),
          "old_password": oldPass,
          "new_password": newPass,
        },
      );

      // In ra để debug nếu gặp lỗi FormatException
      debugPrint("Server response: ${response.body}");

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        showSnackBar(
          data['message'] ?? "Đổi mật khẩu thành công!",
          Colors.green,
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        showSnackBar(data['message'] ?? "Lỗi không xác định", Colors.red);
      }
    } catch (e) {
      debugPrint("Lỗi cụ thể: $e");
      // Sửa lỗi thiếu dấu ; ở đây
      showSnackBar("Lỗi kết nối hoặc định dạng dữ liệu!", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ĐỔI MẬT KHẨU"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPassController,

              decoration: const InputDecoration(
                labelText: "Mật khẩu cũ",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPassController,

              decoration: const InputDecoration(
                labelText: "Mật khẩu mới",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // Khi đang loading thì disable nút (truyền null)
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "CẬP NHẬT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

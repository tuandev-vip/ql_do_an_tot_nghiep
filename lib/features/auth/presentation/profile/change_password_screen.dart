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

  // Biến trạng thái cho mắt thần
  bool _isObscureOld = true;
  bool _isObscureNew = true;

  void showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

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
      appBar: AppBar(
        // 💡 Chữ ĐỔI MẬT KHẨU màu trắng, in đậm
        title: const Text(
          "ĐỔI MẬT KHẨU",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // 💡 Nền AppBar màu xanh
        elevation: 0,
        // 💡 Nút Back màu trắng
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPassController,
              obscureText: _isObscureOld, // Gắn biến ẩn/hiện
              decoration: InputDecoration(
                labelText: "Mật khẩu cũ",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                // 💡 NÚT MẮT THẦN 1
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscureOld ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscureOld = !_isObscureOld;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPassController,
              obscureText: _isObscureNew, // Gắn biến ẩn/hiện
              decoration: InputDecoration(
                labelText: "Mật khẩu mới",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                // 💡 NÚT MẮT THẦN 2
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscureNew ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscureNew = !_isObscureNew;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
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

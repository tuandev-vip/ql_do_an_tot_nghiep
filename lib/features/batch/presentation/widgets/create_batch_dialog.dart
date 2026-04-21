import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ql_do_an_tot_nghiep/main.dart';

class CreateBatchDialog extends StatefulWidget {
  const CreateBatchDialog({super.key});

  @override
  State<CreateBatchDialog> createState() => _CreateBatchDialogState();
}

class _CreateBatchDialogState extends State<CreateBatchDialog> {
  final _nameController = TextEditingController();
  String? _selectedTemplateId;
  List<dynamic> _templates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getTemplates();
  }

  Future<void> _getTemplates() async {
    try {
      // Nhớ thay IP chuẩn của ông vào đây
      final response = await http.get(
        Uri.parse(
          "http://192.168.1.109/ql_do_an_api/api/batch/get_templates.php",
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() => _templates = data['data']);
      }
    } catch (e) {
      debugPrint("Lỗi tải template: $e");
    }
  }

  Future<void> _createBatch() async {
    if (_nameController.text.isEmpty || _selectedTemplateId == null) {
      _showSnackBar("Vui lòng điền đủ thông tin!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse(
              "http://192.168.1.109/ql_do_an_api/api/batch/create_batch.php",
            ),
            body: {
              "batch_name": _nameController.text,
              "template_id": _selectedTemplateId,
            },
          )
          .timeout(const Duration(seconds: 10));

      // Kiểm tra xem dữ liệu có trống không trước khi Decode
      if (response.body.isEmpty) {
        throw Exception("Server trả về dữ liệu trống");
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // Đóng trước, hiện sau cho nó mượt
        if (mounted) Navigator.pop(context);
        _showSnackBar(data['message'], Colors.green);
      } else {
        // Lỗi nghiệp vụ (Trùng đợt) cũng đóng luôn để thoát đơ
        if (mounted) Navigator.pop(context);
        _showSnackBar(data['message'], Colors.red);
      }
    } catch (e) {
      debugPrint("Lỗi API: $e");
      // Khi lỗi cũng phải ĐÓNG DIALOG để người dùng thao tác tiếp được
      if (mounted) Navigator.pop(context);
      _showSnackBar("Có lỗi xảy ra: $e", Colors.red);
    } finally {
      // Dòng này rất quan trọng để dừng cái xoay tròn
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Tạo đợt mới",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên đợt đồ án",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chọn cấu trúc Timeline:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _templates.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _templates.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final t = _templates[index];
                        bool isSelected =
                            _selectedTemplateId == t['template_id'].toString();
                        return ListTile(
                          title: Text(t['template_name']),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                )
                              : null,
                          onTap: () => setState(
                            () => _selectedTemplateId = t['template_id']
                                .toString(),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createBatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Lưu",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

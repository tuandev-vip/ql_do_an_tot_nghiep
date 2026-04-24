import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'package:ql_do_an_tot_nghiep/main.dart';
import 'dart:convert';

import '../../data/models/batch_model.dart';
import '../bloc/batch_bloc.dart';
import '../bloc/batch_event.dart';

class CreateBatchDialog extends StatefulWidget {
  final BatchModel? batch; // Thêm biến này: null là Tạo, có dữ liệu là Cập nhật
  const CreateBatchDialog({super.key, this.batch});

  @override
  State<CreateBatchDialog> createState() => _CreateBatchDialogState();
}

class _CreateBatchDialogState extends State<CreateBatchDialog> {
  late TextEditingController _nameController;
  String? _selectedTemplateId;
  List<dynamic> _templates = [];
  bool _isFetchingTemplates = false;

  @override
  void initState() {
    super.initState();
    // 1. Khởi tạo dữ liệu dựa trên việc là Tạo hay Sửa
    _nameController = TextEditingController(
      text: widget.batch?.batchName ?? "",
    );
    _selectedTemplateId = widget.batch?.templateId;
    _getTemplates();
  }

  // Vẫn giữ hàm này ở đây để lấy danh sách Timeline cấu trúc
  Future<void> _getTemplates() async {
    setState(() => _isFetchingTemplates = true);
    try {
      final response = await http.get(Uri.parse(AppUrls.urlGetTeamplate));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success' && mounted) {
        setState(() => _templates = data['data']);
      }
    } catch (e) {
      debugPrint("Lỗi tải template: $e");
    } finally {
      if (mounted) setState(() => _isFetchingTemplates = false);
    }
  }

  // HÀM XỬ LÝ LƯU (DÙNG BLOC)
  void _onSave() {
    if (_nameController.text.isEmpty || _selectedTemplateId == null) {
      _showSnackBar("Vui lòng điền đủ thông tin!", Colors.orange);
      return;
    }

    if (widget.batch == null) {
      // TRƯỜNG HỢP TẠO MỚI
      context.read<BatchBloc>().add(
        CreateBatchEvent(_nameController.text, _selectedTemplateId!),
      );
    } else {
      // TRƯỜNG HỢP CẬP NHẬT
      context.read<BatchBloc>().add(
        UpdateBatchEvent(
          widget.batch!.batchId,
          _nameController.text,
          _selectedTemplateId!,
        ),
      );
    }

    // Đóng dialog ngay, BLoC sẽ lo việc cập nhật danh sách ở màn hình chính
    Navigator.pop(context);
  }

  void _showSnackBar(String msg, Color color) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isUpdate = widget.batch != null;

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
                Text(
                  isUpdate ? "Cập nhật đợt" : "Tạo đợt mới",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nhập tên đợt...",
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
              height: 136,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isFetchingTemplates
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
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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

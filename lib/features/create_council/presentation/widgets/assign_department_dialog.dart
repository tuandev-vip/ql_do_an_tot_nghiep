import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../bloc/council_bloc.dart';
import '../bloc/council_event.dart';

class AssignDepartmentDialog extends StatefulWidget {
  final int councilId;
  final String councilCode;
  final bool isSchoolLevel;

  const AssignDepartmentDialog({
    super.key,
    required this.councilId,
    required this.councilCode,
    required this.isSchoolLevel,
  });

  @override
  State<AssignDepartmentDialog> createState() => _AssignDepartmentDialogState();
}

class _AssignDepartmentDialogState extends State<AssignDepartmentDialog> {
  // Bản đồ lưu số lượng giảng viên của từng bộ môn
  final Map<String, int> _quotas = {
    'CNPM': 0,
    'HTTT': 0,
    'KHMT': 0,
    'KTMT': 0,
    'MATTT': 0,
  };

  // Tính tổng số lượng đã phân (Tối đa phải bằng 3)
  int get _totalAssigned => _quotas.values.fold(0, (sum, val) => sum + val);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Text(
            "Phân bộ môn",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            widget.councilCode,
            style: const TextStyle(color: Colors.blue, fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Báo đỏ nếu chưa đủ 3 người
          Text(
            "Đã phân: $_totalAssigned/3 giảng viên",
            style: TextStyle(
              color: _totalAssigned == 3 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: _quotas.keys.map((dept) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dept,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quotas[dept]! > 0
                            ? () => setState(
                                () => _quotas[dept] = _quotas[dept]! - 1,
                              )
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        '${_quotas[dept]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _totalAssigned < 3
                            ? () => setState(
                                () => _quotas[dept] = _quotas[dept]! + 1,
                              )
                            : null, // Đủ 3 rồi thì khóa nút + lại
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _totalAssigned == 3
              ? () {
                  // Lọc ra những bộ môn có số lượng > 0 và chuyển thành chuỗi JSON
                  final selectedDepts = Map.fromEntries(
                    _quotas.entries.where((e) => e.value > 0),
                  );
                  final jsonString = jsonEncode(
                    selectedDepts,
                  ); // Ví dụ: {"CNPM":2,"MATTT":1}

                  context.read<CouncilBloc>().add(
                    AssignDepartmentEvent(
                      widget.councilId,
                      jsonString,
                      widget.isSchoolLevel,
                    ),
                  );
                  Navigator.pop(context);
                }
              : null, // Chưa đủ 3 người thì mờ nút Xác nhận đi
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

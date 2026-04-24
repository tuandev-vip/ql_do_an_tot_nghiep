import 'package:flutter/material.dart';

class PendingStudentCard extends StatelessWidget {
  final dynamic student;
  final Function(String regId, String status) onAction;

  const PendingStudentCard({
    super.key,
    required this.student,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student['full_name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn("Mã SV:", student['username']),
                _infoColumn("Lớp:", student['class_name'] ?? "N/A"),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow("Email:", student['email']),
            _infoRow(
              "Hướng đề tài:",
              student['topic_direction'] ?? "Chưa nhập",
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction(student['reg_id'], 'REJECTED'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text(
                      "Từ chối",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction(student['reg_id'], 'APPROVED'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      "Đồng ý",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    ],
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text("$label $value", style: const TextStyle(fontSize: 13)),
  );
}

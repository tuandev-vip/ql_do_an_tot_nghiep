import 'package:flutter/material.dart';
import '../../data/models/auto_assignment_model.dart';

class AutoAssignmentCard extends StatelessWidget {
  final AutoAssignment student;

  const AutoAssignmentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Tên SV và Mã SV
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sinh viên", style: const TextStyle(fontSize: 15)),
              Text(
                student.studentName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Dòng 2: Nhãn "Giảng viên" và Tên giảng viên
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Giảng viên hướng dẫn",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                (student.status == 'APPROVED')
                    ? (student.teacherName ?? "Chưa phân công")
                    : "Chưa phân công", // Nếu chưa APPROVED thì hiện "Chưa phân công" luôn
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (student.status == 'APPROVED')
                      ? Colors.black
                      : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

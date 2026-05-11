import 'package:flutter/material.dart';

class TbmStudentCard extends StatelessWidget {
  final String name;
  final String studentCode;
  final String phone;
  final String className;
  final String email;
  final String projectName;

  const TbmStudentCard({
    super.key,
    required this.name,
    required this.studentCode,
    required this.phone,
    required this.className,
    required this.email,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mã SV:",
                      style: TextStyle(color: Colors.black87),
                    ),
                    Text(
                      studentCode,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text("SĐT:", style: TextStyle(color: Colors.black87)),
                    Text(
                      phone,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Lớp:", style: TextStyle(color: Colors.black87)),
                    Text(
                      className,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Email",
                      style: TextStyle(color: Colors.black87),
                    ),
                    Text(
                      email,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Đề Tài :", style: TextStyle(color: Colors.black87)),
          Text(
            projectName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

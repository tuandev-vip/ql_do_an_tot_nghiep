import 'package:flutter/material.dart';

class RegistrationExpiredView extends StatelessWidget {
  final String batchName;
  final String deadline;

  const RegistrationExpiredView({
    super.key,
    required this.batchName,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.timer_off_outlined,
              size: 100,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            Text(
              "HẾT HẠN ĐĂNG KÝ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Đợt: $batchName",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Hệ thống đã đóng đăng ký vào lúc:\n$deadline",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            const Text(
              "Vui lòng liên hệ Văn phòng Khoa để được hỗ trợ.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

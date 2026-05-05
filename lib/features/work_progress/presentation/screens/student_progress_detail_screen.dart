import 'package:flutter/material.dart';
import '../widgets/student_header_card.dart';
import '../widgets/outline_tab_content.dart';

class StudentProgressDetailScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentProgressDetailScreen({super.key, required this.student});

  @override
  State<StudentProgressDetailScreen> createState() =>
      _StudentProgressDetailScreenState();
}

class _StudentProgressDetailScreenState
    extends State<StudentProgressDetailScreen> {
  int selectedTab = 0; // 0: Duyệt tiến độ, 1: Đề cương

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "QUẢN LÝ ĐÁNH GIÁ ĐỒ ÁN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 1. THANH CHUYỂN TAB
              _buildCustomTabBar(),
              const SizedBox(height: 16),

              // 2. CARD THÔNG TIN SINH VIÊN (Import từ file khác)
              StudentHeaderCard(student: widget.student),
              const SizedBox(height: 16),

              // 3. NỘI DUNG TỪNG TAB
              if (selectedTab == 0)
                const Center(child: Text("Giao diện Duyệt tiến độ (Làm sau)"))
              else
                const OutlineTabContent(), // Gọi Content của Tab Đề cương từ file khác
            ],
          ),
        ),
      ),
    );
  }

  // Thanh Custom Tab Bar tui để lại đây vì nó điều khiển State 'selectedTab' của màn hình chính
  Widget _buildCustomTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => selectedTab = 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: selectedTab == 0
                  ? Colors.lightBlueAccent
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Duyệt tiến độ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedTab == 0 ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => setState(() => selectedTab = 1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: selectedTab == 1
                  ? const Color(0xFF40C4FF)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Đề cương",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedTab == 1 ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/work_progress/presentation/bloc/project_outline_bloc.dart';
// 💡 Đã xóa import student_header_card.dart ở đây
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

              // 💡 ĐÃ CẮT BỎ CÁI CARD THÔNG TIN SINH VIÊN Ở ĐÂY ĐỂ TRỐNG CHỖ CỰC RỘNG RÃI

              // 2. NỘI DUNG TỪNG TAB
              if (selectedTab == 0)
                const Center(child: Text("Giao diện Duyệt tiến độ (Làm sau)"))
              else
                BlocProvider(
                  create: (context) => ProjectOutlineBloc(),
                  child: OutlineTabContent(
                    studentId: widget.student['student_id'],
                    // 💡 Đã xóa cái callback onTopicUpdated vì thẻ Header bị xóa rồi, không cần cập nhật UI ngoài này nữa
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Thanh Custom Tab Bar
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

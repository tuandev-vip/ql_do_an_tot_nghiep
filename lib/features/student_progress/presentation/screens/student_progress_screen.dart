import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import BLoC của GVHD để gọi API
import 'package:ql_do_an_tot_nghiep/features/work_progress/presentation/bloc/project_outline_bloc.dart';
// Import Tab Đề cương ông vừa làm
import '../widgets/student_outline_tab.dart';

class StudentProgressScreen extends StatefulWidget {
  final String studentId;

  const StudentProgressScreen({super.key, required this.studentId});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  int selectedTab = 0; // 0: Báo cáo tiến độ, 1: Đề cương

  late ProjectOutlineBloc _outlineBloc;

  @override
  void initState() {
    super.initState();
    // Khởi tạo BLoC 1 lần duy nhất để lúc chuyển qua chuyển lại 2 tab không bị mất dữ liệu
    _outlineBloc = ProjectOutlineBloc();
  }

  @override
  void dispose() {
    _outlineBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "TIẾN ĐỘ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2962FF), // Xanh đậm chuẩn design
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. KHU VỰC CHUYỂN TAB
          Container(
            color: const Color(0xFFE9ECEF),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                // Nút Tab: Báo cáo tiến độ
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == 0
                            ? const Color(0xFF2962FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Báo cáo tiến độ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedTab == 0
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                // Nút Tab: Đề cương
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == 1
                            ? const Color(0xFF2962FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Đề cương",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedTab == 1
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. NỘI DUNG HIỂN THỊ BÊN DƯỚI
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: selectedTab == 0
                  ? const Center(
                      child: Text("Giao diện Báo cáo tiến độ (Làm sau)"),
                    )
                  : BlocProvider.value(
                      value: _outlineBloc,
                      child: StudentOutlineTab(studentId: widget.studentId),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

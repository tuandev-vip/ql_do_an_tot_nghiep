import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import Bloc dùng chung
import '../../../student_progress/presentation/bloc/student_report_bloc.dart';
import '../../../work_progress/presentation/bloc/project_outline_bloc.dart';

// Import 2 Tab của Giảng viên
import '../widgets/teacher_report_tab.dart';
import '../../../work_progress/presentation/widgets/outline_tab_content.dart';

class TeacherProgressScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const TeacherProgressScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<TeacherProgressScreen> createState() => _TeacherProgressScreenState();
}

class _TeacherProgressScreenState extends State<TeacherProgressScreen> {
  int selectedTab = 0; // 0: Báo cáo tiến độ, 1: Đề cương
  late ProjectOutlineBloc _outlineBloc;

  @override
  void initState() {
    super.initState();
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
        title: Text(
          "Tiến độ: ${widget.studentName}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2962FF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. THANH MENU CHUYỂN TAB (Tui đã code lại cho ông đầy đủ ở đây)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedTab == 0
                            ? const Color(0xFF2962FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "Báo cáo tiến độ",
                          style: TextStyle(
                            color: selectedTab == 0
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedTab == 1
                            ? const Color(0xFF2962FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "Đề cương",
                          style: TextStyle(
                            color: selectedTab == 1
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. NỘI DUNG HIỂN THỊ DƯỚI TAB
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: selectedTab == 0
                  ? BlocProvider(
                      create: (context) => StudentReportBloc(),
                      // Tab chấm điểm báo cáo
                      child: TeacherReportTab(studentId: widget.studentId),
                    )
                  : BlocProvider.value(
                      value: _outlineBloc,
                      child: OutlineTabContent(studentId: widget.studentId),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

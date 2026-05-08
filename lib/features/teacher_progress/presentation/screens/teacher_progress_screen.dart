import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import Bloc dùng chung
import '../../../student_progress/presentation/bloc/student_report_bloc.dart';
import '../../../work_progress/presentation/bloc/project_outline_bloc.dart';

// Import các Tab và Card của Giảng viên & Sinh viên
import '../widgets/teacher_report_tab.dart';
import '../../../work_progress/presentation/widgets/outline_tab_content.dart';
import '../../../work_progress/presentation/widgets/student_header_card.dart'; // 💡 Gọi lại Card hiển thị thông tin ở đây
import '../bloc/teacher_grade_bloc.dart';
import '../widgets/teacher_grade_tab.dart';

class TeacherProgressScreen extends StatefulWidget {
  final Map<String, dynamic> studentData; // 💡 Đổi sang nhận cả cục Data

  const TeacherProgressScreen({super.key, required this.studentData});

  @override
  State<TeacherProgressScreen> createState() => _TeacherProgressScreenState();
}

class _TeacherProgressScreenState extends State<TeacherProgressScreen> {
  int selectedTab = 0; // 0: Báo cáo, 1: Đề cương, 2: Chấm điểm
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
    // 💡 Lấy ID và Tên từ cục data để dùng
    final studentId =
        widget.studentData['student_id']?.toString() ??
        widget.studentData['id']?.toString() ??
        '';
    final studentName =
        widget.studentData['student_name'] ??
        widget.studentData['full_name'] ??
        'Sinh viên';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          "Tiến độ :    $studentName",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2962FF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. GỌI CARD THÔNG TIN SINH VIÊN (Tên, Mã SV, Đề tài...)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: StudentHeaderCard(student: widget.studentData),
          ),

          // 2. THANH MENU CHUYỂN 3 TAB
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTabButton("Báo cáo", 0),
                _buildTabButton("Đề cương", 1),
                _buildTabButton("Chấm điểm", 2), // 💡 Thêm nút Chấm điểm
              ],
            ),
          ),

          // 3. NỘI DUNG HIỂN THỊ DƯỚI TAB
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTabContent(studentId),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hỗ trợ vẽ nút Tab để code đỡ bị dài
  Widget _buildTabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedTab == index
                ? const Color(0xFF2962FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selectedTab == index
                    ? Colors.white
                    : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hỗ trợ chuyển đổi nội dung giữa 3 Tab
  Widget _buildTabContent(String studentId) {
    if (selectedTab == 0) {
      return BlocProvider(
        create: (context) => StudentReportBloc(),
        child: TeacherReportTab(studentId: studentId),
      );
    } else if (selectedTab == 1) {
      return BlocProvider.value(
        value: _outlineBloc,
        child: OutlineTabContent(studentId: studentId),
      );
    } else {
      return BlocProvider(
        create: (context) => TeacherGradeBloc(),
        child: TeacherGradeTab(studentId: studentId),
      );
    }
  }
}

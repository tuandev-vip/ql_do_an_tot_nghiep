import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import Bloc dùng chung
import '../../../student_progress/presentation/bloc/student_report_bloc.dart';
import '../../../work_progress/presentation/bloc/project_outline_bloc.dart';
// Import Tab của Sinh viên (để xem đề cương) và Tab của Giảng viên (để chấm điểm)
import '../../../student_progress/presentation/widgets/student_outline_tab.dart';
import '../widgets/teacher_report_tab.dart';

class TeacherProgressScreen extends StatefulWidget {
  final String studentId;
  final String studentName; // Hiện tên SV lên AppBar cho dễ nhìn

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
          // 1. Thanh Menu chọn Tab (Copy y hệt từ StudentProgressScreen của ông vào đây)
          Container(
            // ... Code tạo Row chứa 2 nút bấm "Báo cáo tiến độ" và "Đề cương"
          ),

          // 2. Nội dung hiển thị
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: selectedTab == 0
                  ? BlocProvider(
                      create: (context) => StudentReportBloc(),
                      child: TeacherReportTab(
                        studentId: widget.studentId,
                      ), // DÙNG TAB CỦA GIẢNG VIÊN
                    )
                  : BlocProvider.value(
                      value: _outlineBloc,
                      child: StudentOutlineTab(
                        studentId: widget.studentId,
                      ), // Dùng chung Tab đề cương của SV
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

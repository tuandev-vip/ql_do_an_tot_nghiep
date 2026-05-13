import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/student/presentation/bloc/student_council_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/student/presentation/widgets/student_council_tab_view.dart';

class StudentCouncilScreen extends StatefulWidget {
  final int currentStudentId; // 💡 Truyền ID sinh viên đang đăng nhập vào đây

  const StudentCouncilScreen({super.key, required this.currentStudentId});

  @override
  State<StudentCouncilScreen> createState() => _StudentCouncilScreenState();
}

class _StudentCouncilScreenState extends State<StudentCouncilScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "THÔNG TIN HỘI ĐỒNG",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2962FF),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: const [
                Tab(text: "Cấp cơ sở"),
                Tab(text: "Cấp trường"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocProvider(
            create: (context) => StudentCouncilBloc(),
            child: StudentCouncilTabView(
              studentId: widget.currentStudentId,
              isSchoolLevel: false,
            ),
          ),
          BlocProvider(
            create: (context) => StudentCouncilBloc(),
            child: StudentCouncilTabView(
              studentId: widget.currentStudentId,
              isSchoolLevel: true,
            ),
          ),
        ],
      ),
    );
  }
}

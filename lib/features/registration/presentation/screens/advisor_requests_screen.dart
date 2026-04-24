import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/registration/presentation/widgets/supervised_student_card.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../widgets/pending_student_card.dart';

class AdvisorRequestsScreen extends StatefulWidget {
  final String teacherId;
  const AdvisorRequestsScreen({super.key, required this.teacherId});

  @override
  State<AdvisorRequestsScreen> createState() => _AdvisorRequestsScreenState();
}

class _AdvisorRequestsScreenState extends State<AdvisorRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RegistrationBloc>().add(
      FetchAdvisorStudentsEvent(widget.teacherId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1, // Mặc định mở tab Duyệt bên phải trước cho tiện
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "QUẢN LÝ SINH VIÊN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.blue[900],
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Danh sách sv"), // Tab bên trái
                  Tab(text: "Duyệt Sv"), // Tab bên phải
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, state) {
            if (state is RegistrationLoading)
              return const Center(child: CircularProgressIndicator());

            if (state is AdvisorStudentsLoaded) {
              return TabBarView(
                children: [
                  // TAB TRÁI: Sinh viên đang hướng dẫn (APPROVED)
                  _buildList(state.approvedStudents, isPending: false),

                  // TAB PHẢI: Sinh viên chờ duyệt (PENDING)
                  _buildList(state.pendingStudents, isPending: true),
                ],
              );
            }
            return const Center(child: Text("Không có dữ liệu"));
          },
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> students, {required bool isPending}) {
    if (students.isEmpty) return const Center(child: Text("Danh sách trống"));

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        if (isPending) {
          return PendingStudentCard(
            student: students[index],
            onAction: (regId, status) {
              context.read<RegistrationBloc>().add(
                UpdateStudentStatusEvent(regId, status, widget.teacherId),
              );
            },
          );
        } else {
          return SupervisedStudentCard(student: students[index]);
        }
      },
    );
  }
}

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Vừa vào là lấy danh sách ngay
    context.read<RegistrationBloc>().add(
      FetchAdvisorStudentsEvent(widget.teacherId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1, // Mặc định mở tab "Duyệt Sv" bên phải
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9), // Nền xám nhạt sang trọng
        appBar: AppBar(
          title: const Text(
            "QUẢN LÝ SINH VIÊN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF2196F3),
          elevation: 0, // Bỏ đổ bóng để nối liền với phần Tab phía dưới
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Nền Tab mờ
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: "Danh sách SV"),
                    Tab(text: "Duyệt sinh viên"),
                  ],
                ),
              ),
            ),

            // 2. THANH TÌM KIẾM - NẰM DƯỚI TAB
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
              child: _buildSearchField(),
            ),

            // 3. DANH SÁCH SINH VIÊN (Dùng Expanded để chiếm phần còn lại)
            Expanded(
              child: BlocBuilder<RegistrationBloc, RegistrationState>(
                builder: (context, state) {
                  if (state is RegistrationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

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
          ],
        ),
      ),
    );
  }

  // Widget Thanh tìm kiếm bo tròn có bóng đổ
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Tìm kiếm mã sinh viên, tên sinh viên,...",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> students, {required bool isPending}) {
    if (students.isEmpty) {
      return const Center(
        child: Text("Danh sách trống", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: students.length,
      padding: const EdgeInsets.only(bottom: 20),
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

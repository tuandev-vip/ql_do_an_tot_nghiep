import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/teacher/presentation/bloc/teacher_council_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/teacher/presentation/bloc/teacher_council_event.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/teacher/presentation/bloc/teacher_council_state.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/teacher/presentation/widgets/teacher_council_detail_screen.dart';

class TeacherCouncilScreen extends StatefulWidget {
  final int teacherId;
  const TeacherCouncilScreen({super.key, required this.teacherId});

  @override
  State<TeacherCouncilScreen> createState() => _TeacherCouncilScreenState();
}

class _TeacherCouncilScreenState extends State<TeacherCouncilScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7F9,
      ), // 💡 Đổi màu nền app sang xám nhạt cho nổi Card
      appBar: AppBar(
        automaticallyImplyLeading: false, // 💡 Ẩn nút mũi tên quay lại
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
            color:
                Colors.white, // 💡 CHÍNH LÀ NÓ ĐÂY: Nền trắng cho thanh TabBar
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
        children: [_buildTabView(false), _buildTabView(true)],
      ),
    );
  }

  Widget _buildTabView(bool isSchool) {
    return BlocProvider(
      create: (context) => TeacherCouncilBloc()
        ..add(
          FetchTeacherCouncilsEvent(
            teacherId: widget.teacherId,
            isSchoolLevel: isSchool,
          ),
        ),
      child: BlocBuilder<TeacherCouncilBloc, TeacherCouncilState>(
        builder: (context, state) {
          if (state is TeacherCouncilLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TeacherCouncilError) {
            return Center(child: Text(state.message));
          }

          if (state is TeacherCouncilLoaded) {
            if (state.viewStatus == 'NO_BATCH') {
              return _buildEmpty("Hiện tại chưa có đợt đồ án.");
            }
            if (state.viewStatus == 'NO_COUNCIL') {
              return _buildEmpty("Chưa được phân công vào hội đồng nào.");
            }

            List councils = state.councils;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: councils.length,
              itemBuilder: (context, index) {
                final c = councils[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherCouncilDetailScreen(
                          councilId:
                              int.tryParse(c['council_id'].toString()) ?? 0,
                          // 💡 SỬA Ở ĐÂY: Truyền thẳng Tên Hội Đồng sang màn chi tiết
                          councilLevel:
                              c['council_name'] ??
                              (isSchool ? "Cấp trường" : "Cơ sở"),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['council_name'] ?? 'Hội đồng',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _rowInfo("Mã hội đồng :", c['council_code']),
                        _rowInfo(
                          "Số lượng SV :",
                          c['student_count'].toString(),
                        ),
                        _rowInfo("Thành viên :", "${c['member_count']}/3"),
                        _rowInfo("Hướng :", c['topic_direction'] ?? "N/A"),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _rowInfo(String label, String val) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmpty(String msg) => Center(
    child: Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 16)),
  );
}

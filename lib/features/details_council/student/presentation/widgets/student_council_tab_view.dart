import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/student/presentation/bloc/student_council_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/student/presentation/bloc/student_council_event.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/student/presentation/bloc/student_council_state.dart';

class StudentCouncilTabView extends StatefulWidget {
  final int studentId;
  final bool isSchoolLevel;

  const StudentCouncilTabView({
    super.key,
    required this.studentId,
    required this.isSchoolLevel,
  });

  @override
  State<StudentCouncilTabView> createState() => _StudentCouncilTabViewState();
}

class _StudentCouncilTabViewState extends State<StudentCouncilTabView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<StudentCouncilBloc>().add(
      FetchStudentCouncilEvent(
        studentId: widget.studentId,
        isSchoolLevel: widget.isSchoolLevel,
        isRefresh: true,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      final state = context.read<StudentCouncilBloc>().state;
      if (state is StudentCouncilLoaded &&
          !state.hasReachedMax &&
          !state.isFetchingMore) {
        context.read<StudentCouncilBloc>().add(
          FetchStudentCouncilEvent(
            studentId: widget.studentId,
            isSchoolLevel: widget.isSchoolLevel,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<StudentCouncilBloc, StudentCouncilState>(
      builder: (context, state) {
        if (state is StudentCouncilLoading)
          return const Center(child: CircularProgressIndicator());

        if (state is StudentCouncilError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is StudentCouncilLoaded) {
          if (state.viewStatus == 'NO_BATCH') {
            return _buildEmptyState("Hiện tại không có đợt đồ án nào.");
          }
          if (state.viewStatus == 'NO_COUNCIL') {
            return _buildEmptyState("Hiện tại chưa có hội đồng");
          }

          final info = state.councilInfo!;
          final students = state.students;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<StudentCouncilBloc>().add(
                FetchStudentCouncilEvent(
                  studentId: widget.studentId,
                  isSchoolLevel: widget.isSchoolLevel,
                  isRefresh: true,
                ),
              );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  students.length +
                  2 +
                  (state.isFetchingMore ? 1 : 0), // +2 cho Header và Tiêu đề DS
              itemBuilder: (context, index) {
                if (index == 0)
                  return _buildCouncilHeader(
                    info['council_code'],
                    info['members'],
                  );
                if (index == 1)
                  return const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      "Danh sách sinh viên trong hội đồng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );

                final studentIndex = index - 2;
                if (studentIndex >= students.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final sv = students[studentIndex];
                return _buildStudentCard(sv);
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouncilHeader(String code, String members) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2962FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Mã hội đồng :",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      code,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Thành viên",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      members,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> sv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sv['full_name'] ?? 'N/A',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Email", sv['email'] ?? 'N/A'),
          _buildInfoRow("Lớp", sv['class_name'] ?? 'N/A'),
          _buildInfoRow("Số điện thoại", sv['phone_number'] ?? 'N/A'),
          _buildInfoRow("Đề Tài :", sv['topic_name'] ?? 'N/A', isTopic: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTopic = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isTopic ? FontWeight.w500 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

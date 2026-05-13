import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/teacher/presentation/bloc/teacher_council_detail_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/teacher/presentation/bloc/teacher_council_detail_event.dart';
import 'package:ql_do_an_tot_nghiep/features/details_council/teacher/presentation/bloc/teacher_council_detail_state.dart';

class TeacherCouncilDetailScreen extends StatefulWidget {
  final int councilId;
  final String councilLevel;
  const TeacherCouncilDetailScreen({
    super.key,
    required this.councilId,
    required this.councilLevel,
  });

  @override
  State<TeacherCouncilDetailScreen> createState() =>
      _TeacherCouncilDetailScreenState();
}

class _TeacherCouncilDetailScreenState
    extends State<TeacherCouncilDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  // 💡 KHAI BÁO BLOC Ở ĐÂY ĐỂ TRÁNH LỖI CONTEXT
  late TeacherCouncilDetailBloc _detailBloc;

  @override
  void initState() {
    super.initState();

    // Khởi tạo BLoC và gọi API lần đầu
    _detailBloc = TeacherCouncilDetailBloc()
      ..add(
        FetchCouncilDetailsEvent(councilId: widget.councilId, isRefresh: true),
      );

    // Lắng nghe sự kiện cuộn (Scroll)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        final state = _detailBloc.state; // Gọi BLoC trực tiếp siêu an toàn

        if (state is DetailLoaded &&
            !state.hasReachedMax &&
            !state.isFetchingMore) {
          _detailBloc.add(
            FetchCouncilDetailsEvent(councilId: widget.councilId),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _detailBloc.close(); // Giải phóng RAM khi thoát màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _detailBloc, // 💡 Truyền BLoC đã tạo ở trên vào UI
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "CHI TIẾT HỘI ĐỒNG",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocBuilder<TeacherCouncilDetailBloc, TeacherCouncilDetailState>(
          builder: (context, state) {
            if (state is DetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DetailError) {
              return Center(child: Text(state.message));
            }

            if (state is DetailLoaded) {
              final info =
                  state.councilInfo ??
                  {'council_code': 'N/A', 'members': 'Chưa có'};
              final students = state.students;

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: students.length + 2 + (state.isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) return _buildHeaderCard(info);
                  if (index == 1) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Danh sách sinh viên trong hội đồng",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  if (index - 2 >= students.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final sv = students[index - 2];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sv['full_name'] ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _row("Email", sv['email'] ?? 'N/A'),
                        _row("Lớp", sv['class_name'] ?? 'N/A'),
                        _row("SĐT", sv['phone_number'] ?? 'N/A'),
                        _row(
                          "Đề tài",
                          sv['topic_name'] ?? 'Chưa có',
                          isTopic: true,
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> info) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blueAccent,
            child: Text(
              widget.councilLevel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _row("Mã hội đồng:", info['council_code'] ?? 'N/A'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 100, // 💡 Đồng bộ width với các Row bên dưới
                      child: Text(
                        "Thành viên:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        info['members'] ?? 'Chưa có',
                        textAlign: TextAlign.right,
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

  Widget _row(String label, String val, {bool isTopic = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100, // 💡 SỬA TỪ 80 THÀNH 100 ĐỂ CHỮ KHÔNG BỊ RỚT DÒNG
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isTopic ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
}

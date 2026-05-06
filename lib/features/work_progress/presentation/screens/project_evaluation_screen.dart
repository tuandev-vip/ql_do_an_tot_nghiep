import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/work_progress/presentation/bloc/project_evaluation_state.dart';
import '../bloc/project_evaluation_bloc.dart';
import '../widgets/evaluation_student_card.dart';
import '../bloc/project_evaluation_event.dart';

class ProjectEvaluationScreen extends StatefulWidget {
  final String teacherId; // Truyền ID giảng viên từ màn hình Dashboard vào

  const ProjectEvaluationScreen({super.key, required this.teacherId});

  @override
  State<ProjectEvaluationScreen> createState() =>
      _ProjectEvaluationScreenState();
}

class _ProjectEvaluationScreenState extends State<ProjectEvaluationScreen> {
  @override
  void initState() {
    super.initState();
    // Vừa vào là gọi API tải dữ liệu ngay
    context.read<ProjectEvaluationBloc>().add(
      FetchEvaluationStudents(widget.teacherId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "QUẢN LÝ ĐÁNH GIÁ ĐỒ ÁN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                // Kích hoạt event tìm kiếm
                context.read<ProjectEvaluationBloc>().add(
                  SearchEvaluationStudent(value),
                );
              },
              decoration: InputDecoration(
                hintText: "Tìm kiếm tên sinh viên.....",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ),

          // 2. DANH SÁCH SINH VIÊN (DÙNG BLOC BUILDER)
          Expanded(
            child: BlocBuilder<ProjectEvaluationBloc, ProjectEvaluationState>(
              builder: (context, state) {
                if (state is EvaluationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EvaluationError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is EvaluationLoaded) {
                  if (state.students.isEmpty) {
                    return const Center(
                      child: Text(
                        "Bạn chưa hướng dẫn sinh viên nào trong đợt này.",
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.students.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      // Đổi model thành dạng Map để nhét vừa vào UI Card cũ của ông
                      return EvaluationStudentCard(
                        student: state.students[index].toMap(),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

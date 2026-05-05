import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_urls.dart'; // Chỉnh lại đường dẫn nếu file của ông nằm chỗ khác
import '../../data/models/evaluation_student_model.dart';
import 'project_evaluation_event.dart';
import 'project_evaluation_state.dart';

class ProjectEvaluationBloc
    extends Bloc<ProjectEvaluationEvent, ProjectEvaluationState> {
  // Lưu cái danh sách gốc lại để lúc search không phải gọi lại API
  List<EvaluationStudentModel> _allStudents = [];

  ProjectEvaluationBloc() : super(EvaluationInitial()) {
    // 1. LẤY DỮ LIỆU TỪ API
    on<FetchEvaluationStudents>((event, emit) async {
      emit(EvaluationLoading());
      try {
        final response = await http.get(
          Uri.parse(
            "${AppUrls.urlgetListStudentTrain}?teacher_id=${event.teacherId}",
          ),
        );

        if (response.statusCode == 200) {
          final dynamic decodedData = json.decode(response.body);

          if (decodedData is List) {
            _allStudents = decodedData
                .map((j) => EvaluationStudentModel.fromJson(j))
                .toList();
            emit(EvaluationLoaded(_allStudents));
          } else if (decodedData is Map && decodedData['status'] == 'error') {
            emit(EvaluationError(decodedData['message']));
          }
        } else {
          emit(EvaluationError("Lỗi kết nối máy chủ: ${response.statusCode}"));
        }
      } catch (e) {
        emit(EvaluationError("Lỗi hệ thống: $e"));
      }
    });

    // 2. TÌM KIẾM OFFLINE TRÊN APP
    on<SearchEvaluationStudent>((event, emit) {
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(EvaluationLoaded(_allStudents)); // Rỗng thì nhả lại full danh sách
      } else {
        final filtered = _allStudents.where((student) {
          return student.studentName.toLowerCase().contains(query) ||
              student.studentCode.toLowerCase().contains(query);
        }).toList();

        emit(EvaluationLoaded(filtered)); // Nhả ra danh sách đã lọc
      }
    });
  }
}

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_urls.dart';
import '../../data/models/auto_assignment_model.dart';
import 'auto_assignment_event.dart';
import 'auto_assignment_state.dart';

class AutoAssignmentBloc
    extends Bloc<AutoAssignmentEvent, AutoAssignmentState> {
  AutoAssignmentBloc() : super(AutoAssignmentInitial()) {
    on<FetchAutoAssignmentStudents>((event, emit) async {
      emit(AutoAssignmentLoading());
      try {
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/teacher/get_auto_assignment_students.php?filter=${event.filter}&dept_id=${event.deptId}",
          ),
        );

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          final students = data.map((e) => AutoAssignment.fromJson(e)).toList();
          emit(AutoAssignmentLoaded(students));
        } else {
          emit(AutoAssignmentError("Lỗi kết nối máy chủ"));
        }
      } catch (e) {
        emit(AutoAssignmentError("Lỗi hệ thống: $e"));
      }
    });

    on<TriggerAutoAssign>((event, emit) async {
      emit(AutoAssignmentLoading());
      try {
        final response = await http.post(
          Uri.parse(
            "${AppUrls.baseUrl}/api/teacher/process_auto_assignment.php",
          ),
          body: json.encode({'dept_id': event.deptId}),
          headers: {"Content-Type": "application/json"},
        );

        final resData = json.decode(response.body);
        if (resData['status'] == 'success') {
          // Sau khi phân xong, tự động load lại danh sách để TBM thấy kết quả
          add(FetchAutoAssignmentStudents("all", event.deptId));
        } else {
          emit(AutoAssignmentError(resData['message'] ?? "Phân công thất bại"));
        }
      } catch (e) {
        emit(AutoAssignmentError("Lỗi logic: $e"));
      }
    });
  }
}

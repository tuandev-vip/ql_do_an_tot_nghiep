import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'dart:convert';
import 'teacher_council_event.dart';
import 'teacher_council_state.dart';

class TeacherCouncilBloc
    extends Bloc<TeacherCouncilEvent, TeacherCouncilState> {
  TeacherCouncilBloc() : super(TeacherCouncilInitial()) {
    on<FetchTeacherCouncilsEvent>((event, emit) async {
      emit(TeacherCouncilLoading());
      try {
        String isSchoolStr = event.isSchoolLevel ? 'true' : 'false';
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/teacher/get_teacher_councils.php?teacher_id=${event.teacherId}&is_school=$isSchoolStr",
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            emit(
              TeacherCouncilLoaded(
                viewStatus: data['view_status'],
                councils: data['councils'] ?? [],
              ),
            );
          } else {
            emit(TeacherCouncilError(data['message'] ?? "Lỗi tải dữ liệu"));
          }
        } else {
          emit(TeacherCouncilError("Lỗi máy chủ: ${response.statusCode}"));
        }
      } catch (e) {
        emit(TeacherCouncilError("Lỗi hệ thống: $e"));
      }
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'dart:convert';
import 'student_council_event.dart';
import 'student_council_state.dart';

class StudentCouncilBloc
    extends Bloc<StudentCouncilEvent, StudentCouncilState> {
  int _currentPage = 1;
  final int _limit = 5;

  StudentCouncilBloc() : super(StudentCouncilInitial()) {
    on<FetchStudentCouncilEvent>((event, emit) async {
      if (event.isRefresh) {
        _currentPage = 1;
        emit(StudentCouncilLoading());
      }

      final currentState = state;
      if (currentState is StudentCouncilLoaded &&
          currentState.hasReachedMax &&
          !event.isRefresh)
        return;

      if (currentState is StudentCouncilLoaded && !event.isRefresh) {
        emit(currentState.copyWith(isFetchingMore: true));
      }

      try {
        String isSchoolStr = event.isSchoolLevel ? 'true' : 'false';
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/student/get_student_council.php?student_id=${event.studentId}&is_school=$isSchoolStr&page=$_currentPage&limit=$_limit",
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            String viewStatus = data['view_status'];

            // Nếu không có đợt hoặc chưa có hội đồng -> Dừng luôn, ko cần list
            if (viewStatus == 'NO_BATCH' || viewStatus == 'NO_COUNCIL') {
              emit(StudentCouncilLoaded(viewStatus: viewStatus, students: []));
              return;
            }

            final List<dynamic> newStudents = data['students'] ?? [];

            if (currentState is StudentCouncilLoaded && !event.isRefresh) {
              emit(
                currentState.copyWith(
                  students: List.of(currentState.students)..addAll(newStudents),
                  hasReachedMax: newStudents.length < _limit,
                  isFetchingMore: false,
                ),
              );
            } else {
              emit(
                StudentCouncilLoaded(
                  viewStatus: viewStatus,
                  councilInfo: data['council_info'],
                  students: newStudents,
                  hasReachedMax: newStudents.length < _limit,
                ),
              );
            }
            _currentPage++;
          } else {
            emit(StudentCouncilError(data['message'] ?? "Lỗi tải dữ liệu"));
          }
        } else {
          emit(StudentCouncilError("Lỗi máy chủ: ${response.statusCode}"));
        }
      } catch (e) {
        emit(StudentCouncilError("Lỗi kết nối: $e"));
      }
    });
  }
}

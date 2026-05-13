import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'dart:convert';
import 'teacher_council_detail_event.dart';
import 'teacher_council_detail_state.dart';

class TeacherCouncilDetailBloc
    extends Bloc<TeacherCouncilDetailEvent, TeacherCouncilDetailState> {
  int _currentPage = 1;
  final int _limit = 5;

  TeacherCouncilDetailBloc() : super(DetailInitial()) {
    on<FetchCouncilDetailsEvent>((event, emit) async {
      if (event.isRefresh) {
        _currentPage = 1;
        emit(DetailLoading());
      }

      final currentState = state;
      if (currentState is DetailLoaded &&
          currentState.hasReachedMax &&
          !event.isRefresh)
        return;

      if (currentState is DetailLoaded && !event.isRefresh) {
        emit(currentState.copyWith(isFetchingMore: true));
      }

      try {
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/teacher/get_teacher_council_details.php?council_id=${event.councilId}&page=$_currentPage&limit=$_limit",
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            final List<dynamic> newStudents = data['students'] ?? [];

            if (currentState is DetailLoaded && !event.isRefresh) {
              emit(
                currentState.copyWith(
                  students: List.of(currentState.students)..addAll(newStudents),
                  hasReachedMax: newStudents.length < _limit,
                  isFetchingMore: false,
                ),
              );
            } else {
              emit(
                DetailLoaded(
                  councilInfo: data['council_info'],
                  students: newStudents,
                  hasReachedMax: newStudents.length < _limit,
                ),
              );
            }
            _currentPage++;
          } else {
            emit(DetailError(data['message'] ?? "Lỗi dữ liệu chi tiết"));
          }
        }
      } catch (e) {
        emit(DetailError("Lỗi hệ thống: $e"));
      }
    });
  }
}

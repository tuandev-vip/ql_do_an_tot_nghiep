import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tbm_council_detail_event.dart';
import 'tbm_council_detail_state.dart';
import '../../../../core/constants/app_urls.dart';

class TbmCouncilDetailBloc
    extends Bloc<TbmCouncilDetailEvent, TbmCouncilDetailState> {
  int _currentPage = 1;
  final int _limit = 5; // 💡 Chuẩn bài limit 5

  TbmCouncilDetailBloc() : super(DetailInitial()) {
    on<FetchStudentsEvent>((event, emit) async {
      if (event.isRefresh) {
        _currentPage = 1;
        emit(DetailLoading());
      }

      final currentState = state;
      if (currentState is DetailLoaded &&
          currentState.hasReachedMax &&
          !event.isRefresh) {
        return;
      }

      if (currentState is DetailLoaded && !event.isRefresh) {
        emit(currentState.copyWith(isFetchingMore: true));
      }

      try {
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/council/get_tbm_council_students.php?council_id=${event.councilId}&page=$_currentPage&limit=$_limit",
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
                  students: newStudents,
                  hasReachedMax: newStudents.length < _limit,
                  isFetchingMore: false,
                ),
              );
            }
            _currentPage++;
          } else {
            emit(DetailError(data['message'] ?? "Lỗi tải dữ liệu"));
          }
        }
      } catch (e) {
        emit(DetailError("Lỗi thực sự là: $e"));
      }
    });
  }
}

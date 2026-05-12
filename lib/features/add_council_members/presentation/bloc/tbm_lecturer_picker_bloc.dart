import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tbm_lecturer_picker_event.dart';
import 'tbm_lecturer_picker_state.dart';
import '../../../../core/constants/app_urls.dart';

class TbmLecturerPickerBloc
    extends Bloc<TbmLecturerPickerEvent, TbmLecturerPickerState> {
  int _currentPage = 1;
  final int _limit = 5;

  TbmLecturerPickerBloc() : super(PickerInitial()) {
    on<FetchLecturersEvent>((event, emit) async {
      if (event.isRefresh) {
        _currentPage = 1;
        emit(PickerLoading());
      }

      final currentState = state;
      if (currentState is PickerLoaded &&
          currentState.hasReachedMax &&
          !event.isRefresh) {
        return;
      }

      if (currentState is PickerLoaded && !event.isRefresh)
        emit(currentState.copyWith(isFetchingMore: true));

      try {
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/council/get_tbm_council_lecturers.php?dept_code=${event.deptCode}&page=$_currentPage&limit=$_limit",
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            final List<dynamic> newLecturers = data['lecturers'] ?? [];
            if (currentState is PickerLoaded && !event.isRefresh) {
              emit(
                currentState.copyWith(
                  lecturers: List.of(currentState.lecturers)
                    ..addAll(newLecturers),
                  hasReachedMax: newLecturers.length < _limit,
                  isFetchingMore: false,
                ),
              );
            } else {
              emit(
                PickerLoaded(
                  lecturers: newLecturers,
                  hasReachedMax: newLecturers.length < _limit,
                ),
              );
            }
            _currentPage++;
          } else {
            emit(PickerError(data['message'] ?? "Lỗi tải dữ liệu"));
          }
        }
      } catch (e) {
        emit(PickerError("Lỗi kết nối mạng: $e"));
      }
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/untils/time_manager.dart';
import 'council_event.dart';
import 'council_state.dart';
import 'package:flutter/foundation.dart';

class CouncilBloc extends Bloc<CouncilEvent, CouncilState> {
  int _currentPage = 1;
  final int _limit = 20;

  CouncilBloc() : super(CouncilInitial()) {
    // ==========================================
    // LẤY THÔNG TIN DANH SÁCH
    // ==========================================
    on<FetchCouncilInfoEvent>((event, emit) async {
      if (event.isRefresh) {
        _currentPage = 1;
        emit(CouncilLoading());
      }

      final currentState = state;

      if (currentState is CouncilLoaded &&
          currentState.hasReachedMax &&
          !event.isRefresh) {
        return;
      }

      if (currentState is CouncilLoaded && !event.isRefresh) {
        emit(currentState.copyWith(isFetchingMore: true));
      } else if (!event.isRefresh) {
        emit(CouncilLoading());
      }

      try {
        String fakeTime = (TimeManager.now().millisecondsSinceEpoch ~/ 1000)
            .toString();

        // 💡 SỬA LỖI 1: Bắt cờ isSchoolLevel chuyển thành chuỗi
        String isSchoolStr = event.isSchoolLevel ? 'true' : 'false';

        // 💡 SỬA LỖI 2: Gắn is_school=$isSchoolStr vào URL
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/council/get_council_cs_info.php?is_school=$isSchoolStr&fake_time=$fakeTime&page=$_currentPage&limit=$_limit",
          ),
        );

        if (response.statusCode == 200) {
          final data = await compute(jsonDecode, response.body);
          if (data['status'] == 'success') {
            final List<dynamic> newCouncils = data['councils'] ?? [];

            if (currentState is CouncilLoaded && !event.isRefresh) {
              emit(
                currentState.copyWith(
                  councils: List.of(currentState.councils)..addAll(newCouncils),
                  hasReachedMax: newCouncils.length < _limit,
                  isFetchingMore: false,
                ),
              );
            } else {
              emit(
                CouncilLoaded(
                  createTimeStatus: data['create_time_status'] ?? "OPEN",
                  assignTimeStatus: data['assign_time_status'] ?? "OPEN",
                  totalStudents: data['total_students'] ?? 0,
                  councils: newCouncils,
                  hasReachedMax: newCouncils.length < _limit,
                  isFetchingMore: false,
                ),
              );
            }
            _currentPage++;
          } else {
            emit(CouncilError(data['message'] ?? "Lỗi tải dữ liệu"));
          }
        } else {
          emit(CouncilError("Lỗi máy chủ: ${response.statusCode}"));
        }
      } catch (e) {
        emit(CouncilError("Lỗi hệ thống: $e"));
      }
    });

    // ==========================================
    // TẠO HỘI ĐỒNG TỰ ĐỘNG
    // ==========================================
    on<AutoCreateCouncilEvent>((event, emit) async {
      emit(CouncilLoading());
      try {
        String fakeTime = (TimeManager.now().millisecondsSinceEpoch ~/ 1000)
            .toString();

        final response = await http.post(
          Uri.parse(
            "${AppUrls.baseUrl}/api/council/auto_create_councils_cs.php",
          ),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "capacity": event.capacity,
            "is_school": event.isSchoolLevel,
            "fake_time": fakeTime,
          }),
        );

        if (response.statusCode == 200) {
          final data = await compute(jsonDecode, response.body);
          if (data['status'] == 'success') {
            emit(CouncilActionSuccess(data['message']));
            // 💡 SỬA LỖI 3: Gửi kèm isSchoolLevel để nó refresh đúng Tab
            add(
              FetchCouncilInfoEvent(
                isSchoolLevel: event.isSchoolLevel,
                isRefresh: true,
              ),
            );
          } else {
            emit(CouncilError(data['message'] ?? "Lỗi tạo hội đồng"));
            add(
              FetchCouncilInfoEvent(
                isSchoolLevel: event.isSchoolLevel,
                isRefresh: true,
              ),
            );
          }
        } else {
          emit(CouncilError("Lỗi máy chủ: ${response.statusCode}"));
          add(
            FetchCouncilInfoEvent(
              isSchoolLevel: event.isSchoolLevel,
              isRefresh: true,
            ),
          );
        }
      } catch (e) {
        emit(CouncilError("Lỗi hệ thống: $e"));
        add(
          FetchCouncilInfoEvent(
            isSchoolLevel: event.isSchoolLevel,
            isRefresh: true,
          ),
        );
      }
    });

    // ==========================================
    // PHÂN BỘ MÔN (Chỉ dành cho Cấp cơ sở)
    // ==========================================
    on<AssignDepartmentEvent>((event, emit) async {
      emit(CouncilLoading());
      try {
        final response = await http.post(
          Uri.parse("${AppUrls.baseUrl}/api/council/assign_department_cs.php"),
          body: {
            "council_id": event.councilId.toString(),
            "department_data": event.departmentData,
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            emit(CouncilActionSuccess(data['message']));
            // Phân xong thì tải lại trang 1
            add(
              FetchCouncilInfoEvent(
                isSchoolLevel: event.isSchoolLevel,
                isRefresh: true,
              ),
            );
          } else {
            emit(CouncilError(data['message'] ?? "Lỗi phân bộ môn"));
            add(
              FetchCouncilInfoEvent(
                isSchoolLevel: event.isSchoolLevel,
                isRefresh: true,
              ),
            );
          }
        } else {
          emit(CouncilError("Lỗi máy chủ: ${response.statusCode}"));
        }
      } catch (e) {
        emit(CouncilError("Lỗi hệ thống: $e"));
      }
    });
  }
}

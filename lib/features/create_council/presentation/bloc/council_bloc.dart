import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/untils/time_manager.dart';
import 'council_event.dart';
import 'council_state.dart';
import 'package:flutter/foundation.dart';

class CouncilBloc extends Bloc<CouncilEvent, CouncilState> {
  int _currentPage = 1; // 💡 Trang hiện tại
  final int _limit = 20; // 💡 Mỗi lần kéo load 20 item

  CouncilBloc() : super(CouncilInitial()) {
    // LẤY THÔNG TIN
    on<FetchCouncilInfoEvent>((event, emit) async {
      // 1. Kiểm tra nếu là vuốt Refresh hoặc gọi lại từ đầu thì reset Trang 1
      if (event.isRefresh) {
        _currentPage = 1;
        emit(CouncilLoading());
      }

      final currentState = state;

      // 2. Chặn không gọi API nếu đã tải hết sạch dữ liệu từ trước
      if (currentState is CouncilLoaded &&
          currentState.hasReachedMax &&
          !event.isRefresh) {
        return;
      }

      // 3. Hiện vòng quay loading xoay xoay ở đáy màn hình nếu đang tải thêm
      if (currentState is CouncilLoaded && !event.isRefresh) {
        emit(currentState.copyWith(isFetchingMore: true));
      } else if (!event.isRefresh) {
        emit(CouncilLoading()); // Loading toàn màn hình cho lần đầu
      }

      try {
        String fakeTime = (TimeManager.now().millisecondsSinceEpoch ~/ 1000)
            .toString();

        // 💡 4. Truyền biến page và limit xuống API PHP
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/council/get_council_cs_info.php?fake_time=$fakeTime&page=$_currentPage&limit=$_limit",
          ),
        );

        if (response.statusCode == 200) {
          final data = await compute(jsonDecode, response.body);
          if (data['status'] == 'success') {
            final List<dynamic> newCouncils = data['councils'] ?? [];

            if (currentState is CouncilLoaded && !event.isRefresh) {
              // 💡 5A. NẾU ĐANG CUỘN: Nối thêm 20 thẻ mới vào sau danh sách cũ
              emit(
                currentState.copyWith(
                  councils: List.of(currentState.councils)..addAll(newCouncils),
                  hasReachedMax:
                      newCouncils.length <
                      _limit, // Ít hơn 20 nghĩa là kịch kim rồi
                  isFetchingMore: false,
                ),
              );
            } else {
              // 💡 5B. NẾU LÀ LẦN ĐẦU VÀO APP HOẶC REFRESH: Xây danh sách gốc
              emit(
                CouncilLoaded(
                  // 💡 SỬA Ở ĐÂY: Dùng 2 biến thời gian mới tách ra từ API
                  createTimeStatus: data['create_time_status'] ?? "OPEN",
                  assignTimeStatus: data['assign_time_status'] ?? "OPEN",
                  totalStudents: data['total_students'] ?? 0,
                  councils: newCouncils,
                  hasReachedMax: newCouncils.length < _limit,
                  isFetchingMore: false,
                ),
              );
            }

            _currentPage++; // Tăng trang lên 1 để chuẩn bị cho lần lướt tiếp theo
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

    // TẠO TỰ ĐỘNG
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
            // 💡 QUAN TRỌNG: Tạo xong phải có isRefresh: true để tải lại từ trang 1
            add(FetchCouncilInfoEvent(isRefresh: true));
          } else {
            emit(CouncilError(data['message'] ?? "Lỗi tạo hội đồng"));
            add(FetchCouncilInfoEvent(isRefresh: true));
          }
        } else {
          emit(CouncilError("Lỗi máy chủ: ${response.statusCode}"));
          add(FetchCouncilInfoEvent(isRefresh: true));
        }
      } catch (e) {
        emit(CouncilError("Lỗi hệ thống: $e"));
        add(FetchCouncilInfoEvent(isRefresh: true));
      }
    });

    // PHÂN BỘ MÔN CHO HỘI ĐỒNG TỔNG HỢP
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
            // Phân xong thì tải lại trang 1 cho mới data
            add(FetchCouncilInfoEvent(isRefresh: true));
          } else {
            emit(CouncilError(data['message'] ?? "Lỗi phân bộ môn"));
            add(FetchCouncilInfoEvent(isRefresh: true));
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

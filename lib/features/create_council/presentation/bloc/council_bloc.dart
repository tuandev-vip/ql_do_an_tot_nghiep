import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/untils/time_manager.dart';
import 'council_event.dart';
import 'council_state.dart';

class CouncilBloc extends Bloc<CouncilEvent, CouncilState> {
  CouncilBloc() : super(CouncilInitial()) {
    // LẤY THÔNG TIN
    on<FetchCouncilInfoEvent>((event, emit) async {
      emit(CouncilLoading());
      try {
        String fakeTime = (TimeManager.now().millisecondsSinceEpoch ~/ 1000)
            .toString();

        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/council/get_council_cs_info.php?fake_time=$fakeTime",
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            emit(
              CouncilLoaded(
                timeStatus: data['time_status'] ?? "OPEN",
                totalStudents: data['total_students'] ?? 0,
                councils: data['councils'] ?? [],
              ),
            );
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
            "fake_time": fakeTime,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            emit(CouncilActionSuccess(data['message']));
            add(FetchCouncilInfoEvent());
          } else {
            emit(CouncilError(data['message'] ?? "Lỗi tạo hội đồng"));
            add(FetchCouncilInfoEvent());
          }
        } else {
          emit(CouncilError("Lỗi máy chủ: ${response.statusCode}"));
          add(FetchCouncilInfoEvent());
        }
      } catch (e) {
        emit(CouncilError("Lỗi hệ thống: $e"));
        add(FetchCouncilInfoEvent());
      }
    });
  }
}

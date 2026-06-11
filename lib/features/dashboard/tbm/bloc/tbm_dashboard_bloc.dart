import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';
import 'tbm_dashboard_event.dart';
import 'tbm_dashboard_state.dart';

class TbmDashboardBloc extends Bloc<TbmDashboardEvent, TbmDashboardState> {
  TbmDashboardBloc() : super(TbmDashboardInitial()) {
    on<LoadTbmDashboardStats>(_onLoadStats);
    on<GenerateAIStatsEvent>(_onGenerateAIStats);
  }

  Future<void> _onLoadStats(
    LoadTbmDashboardStats event,
    Emitter<TbmDashboardState> emit,
  ) async {
    emit(TbmDashboardLoading());
    try {
      final url = Uri.parse(
        "${AppUrls.baseUrl}/api/department_head/get_tbm_stats.php?dept_id=${event.deptId}",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // 💡 PHẢI CÓ ĐOẠN NÀY ĐỂ BỐC NGÀY THÁNG TỪ PHP NẠP VÀO FLUTTER
          DateTime? parsedOutline;
          DateTime? parsedW10;

          if (data['data']['outline_deadline'] != null) {
            parsedOutline = DateTime.tryParse(
              data['data']['outline_deadline'].toString(),
            );
          }
          if (data['data']['report_w10_deadline'] != null) {
            parsedW10 = DateTime.tryParse(
              data['data']['report_w10_deadline'].toString(),
            );
          }

          emit(
            TbmDashboardLoaded(
              totalStudents:
                  int.tryParse(data['data']['total_students'].toString()) ?? 0,
              totalTeachers:
                  int.tryParse(data['data']['total_teachers'].toString()) ?? 0,
              noAdvisor:
                  int.tryParse(data['data']['no_advisor'].toString()) ?? 0,
              missingMembers:
                  int.tryParse(data['data']['missing_members'].toString()) ?? 0,
              hasBatch: data['data']['has_batch'] ?? false,
              // 💡 GÁN 2 BIẾN NÀY VÀO STATE THÌ UI MỚI NHẬN ĐƯỢC GIỜ ĐỂ MỞ KHÓA NÚT
              outlineDeadline: parsedOutline,
              reportW10Deadline: parsedW10,
            ),
          );
        } else {
          emit(TbmDashboardError(data['message'] ?? "Lỗi lấy dữ liệu"));
        }
      } else {
        emit(TbmDashboardError("Lỗi kết nối máy chủ: ${response.statusCode}"));
      }
    } catch (e) {
      emit(TbmDashboardError("Lỗi hệ thống: ${e.toString()}"));
    }
  }

  Future<void> _onGenerateAIStats(
    GenerateAIStatsEvent event,
    Emitter<TbmDashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TbmDashboardLoaded) return;

    emit(currentState.copyWith(isAILoading: true, aiError: null));

    try {
      final url = Uri.parse(
        "${AppUrls.baseUrl}/api/department_head/generate_ai_stats.php",
      );

      String currentTimeStr = TimeManager.now().toString().split('.').first;

      final response = await http.post(
        url,
        body: {
          'dept_id': event.deptId,
          'week_num': event.weekNum.toString(),
          'client_time': currentTimeStr, // 💡 Gửi thời gian chuẩn lên Server
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          emit(
            currentState.copyWith(
              isAILoading: false,
              aiSummary: data['ai_summary'],
            ),
          );
        } else {
          emit(
            currentState.copyWith(isAILoading: false, aiError: data['message']),
          );
        }
      } else {
        emit(
          currentState.copyWith(
            isAILoading: false,
            aiError: "Lỗi Server ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isAILoading: false,
          aiError: "Lỗi mạng: ${e.toString()}",
        ),
      );
    }
  }
}

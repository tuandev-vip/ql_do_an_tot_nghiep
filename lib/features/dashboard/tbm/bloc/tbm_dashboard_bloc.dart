import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'tbm_dashboard_event.dart';
import 'tbm_dashboard_state.dart';

class TbmDashboardBloc extends Bloc<TbmDashboardEvent, TbmDashboardState> {
  TbmDashboardBloc() : super(TbmDashboardInitial()) {
    on<LoadTbmDashboardStats>(_onLoadStats);
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
          emit(
            TbmDashboardLoaded(
              totalStudents: data['data']['total_students'],
              totalTeachers: data['data']['total_teachers'],
              noAdvisor: data['data']['no_advisor'],
              missingMembers: data['data']['missing_members'],
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
}

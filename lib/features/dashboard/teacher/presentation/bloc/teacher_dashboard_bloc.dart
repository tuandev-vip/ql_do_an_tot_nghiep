import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../core/constants/app_urls.dart'; // Đổi đường dẫn cho khớp dự án của ông
import 'teacher_dashboard_event.dart';
import 'teacher_dashboard_state.dart';

class TeacherDashboardBloc
    extends Bloc<TeacherDashboardEvent, TeacherDashboardState> {
  TeacherDashboardBloc() : super(DashboardLoading()) {
    on<FetchTeacherDashboard>((event, emit) async {
      emit(DashboardLoading());
      try {
        final res = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/teacher/get_teacher_dashboard.php?teacher_id=${event.teacherId}",
          ),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'success') {
            emit(
              DashboardLoaded(
                viewStatus: data['view_status'] ?? 'NO_BATCH',
                totalStudents:
                    int.tryParse(data['total_students'].toString()) ?? 0,
                statistics: data['statistics'] ?? [],
              ),
            );
          } else {
            emit(DashboardError(data['message'] ?? "Lỗi tải dữ liệu"));
          }
        } else {
          emit(DashboardError("Lỗi server"));
        }
      } catch (e) {
        emit(DashboardError("Lỗi kết nối: $e"));
      }
    });
  }
}

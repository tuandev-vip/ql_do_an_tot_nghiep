import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../core/constants/app_urls.dart';
// 💡 IMPORT FILE THỜI GIAN ĐỂ FAKE TIME
import '../../../../../core/untils/time_manager.dart';
import 'teacher_dashboard_event.dart';
import 'teacher_dashboard_state.dart';

class TeacherDashboardBloc
    extends Bloc<TeacherDashboardEvent, TeacherDashboardState> {
  TeacherDashboardBloc() : super(DashboardLoading()) {
    on<FetchTeacherDashboard>((event, emit) async {
      emit(DashboardLoading());
      try {
        // 1. URL Lấy thống kê của Giảng viên
        final urlStats = Uri.parse(
          "${AppUrls.baseUrl}/api/teacher/get_teacher_dashboard.php?teacher_id=${event.teacherId}",
        );

        // 💡 2. URL Gọi ngầm Thông báo để hệ thống tính Fake Time
        String currentTimeStr = TimeManager.now().toString().split('.').first;
        String encodedTime = Uri.encodeComponent(currentTimeStr);
        final urlNoti = Uri.parse(
          "${AppUrls.baseUrl}/api/notifications/get_notifications.php?user_id=${event.teacherId}&role=GIANG_VIEN&client_time=$encodedTime",
        );

        // Gọi 2 API cùng lúc
        final resStats = await http.get(urlStats);
        final resNoti = await http.get(urlNoti); // Gọi ngầm

        if (resStats.statusCode == 200) {
          final data = jsonDecode(resStats.body);

          if (data['status'] == 'success') {
            // 💡 3. XỬ LÝ LẤY CHẤM ĐỎ
            bool unreadStatus = false;
            if (resNoti.statusCode == 200) {
              final dataNoti = jsonDecode(resNoti.body);
              if (dataNoti['status'] == 'success') {
                unreadStatus =
                    dataNoti['has_unread'] == true ||
                    dataNoti['has_unread'] == 1;
              }
            }

            emit(
              DashboardLoaded(
                viewStatus: data['view_status'] ?? 'NO_BATCH',
                totalStudents:
                    int.tryParse(data['total_students'].toString()) ?? 0,
                statistics: data['statistics'] ?? [],
                // 💡 4. GÁN CHẤM ĐỎ VÀO TRẠNG THÁI
                hasUnread: unreadStatus,
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

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';

import 'student_dashboard_event.dart';
import 'student_dashboard_state.dart';

class StudentDashboardBloc
    extends Bloc<StudentDashboardEvent, StudentDashboardState> {
  StudentDashboardBloc() : super(StudentDashboardInitial()) {
    on<LoadStudentDashboardStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(
    LoadStudentDashboardStats event,
    Emitter<StudentDashboardState> emit,
  ) async {
    emit(StudentDashboardLoading());

    try {
      // 1. URL Gọi API lấy thông tin đồ án của sinh viên (Ông cần viết file PHP này nhé)
      final urlStats = Uri.parse(
        "${AppUrls.baseUrl}/api/student/get_student_dashboard.php?student_id=${event.studentId}",
      );

      // 2. URL Gọi ngầm Thông báo để hệ thống tính Fake Time & Đẻ thông báo
      String currentTimeStr = TimeManager.now().toString().split('.').first;
      String encodedTime = Uri.encodeComponent(currentTimeStr);
      final urlNoti = Uri.parse(
        "${AppUrls.baseUrl}/api/notifications/get_notifications.php?user_id=${event.studentId}&role=SINH_VIEN&client_time=$encodedTime",
      );

      final responseStats = await http.get(urlStats);
      final responseNoti = await http.get(urlNoti);

      if (responseStats.statusCode == 200) {
        final data = jsonDecode(responseStats.body);

        if (data['status'] == 'success') {
          // Lấy dữ liệu chấm đỏ
          bool unreadStatus = false;
          if (responseNoti.statusCode == 200) {
            final dataNoti = jsonDecode(responseNoti.body);
            if (dataNoti['status'] == 'success') {
              unreadStatus =
                  dataNoti['has_unread'] == true || dataNoti['has_unread'] == 1;
            }
          }

          // Xử lý Timeline (Parse ngày tháng từ JSON)
          Map<String, dynamic> batchData =
              data['data']['batch_deadlines'] ?? {};
          Map<String, DateTime?> parsedDeadlines = {
            "Nộp Đề Cương": _parseDate(batchData['outline_deadline']),
            "Báo cáo Tuần 1": _parseDate(batchData['report_w1_deadline']),
            "Báo cáo Tuần 2": _parseDate(batchData['report_w2_deadline']),
            "Báo cáo Tuần 3": _parseDate(batchData['report_w3_deadline']),
            "Báo cáo Tuần 4": _parseDate(batchData['report_w4_deadline']),
            "Báo cáo Tuần 5": _parseDate(batchData['report_w5_deadline']),
            "Báo cáo Tuần 6": _parseDate(batchData['report_w6_deadline']),
            "Báo cáo Tuần 7": _parseDate(batchData['report_w7_deadline']),
            "Báo cáo Tuần 8": _parseDate(batchData['report_w8_deadline']),
            "Báo cáo Tuần 9": _parseDate(batchData['report_w9_deadline']),
            "Báo cáo Tuần 10": _parseDate(batchData['report_w10_deadline']),
          };

          emit(
            StudentDashboardLoaded(
              hasBatch: data['data']['has_batch'] ?? false,
              advisorName: data['data']['advisor_name'],
              topicName: data['data']['topic_name'],
              deadlines: parsedDeadlines,
              hasUnread: unreadStatus,
            ),
          );
        } else {
          emit(StudentDashboardError(data['message'] ?? "Lỗi tải dữ liệu"));
        }
      } else {
        emit(StudentDashboardError("Lỗi server: ${responseStats.statusCode}"));
      }
    } catch (e) {
      emit(StudentDashboardError("Lỗi kết nối: $e"));
    }
  }

  DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    return DateTime.tryParse(dateStr.toString());
  }
}

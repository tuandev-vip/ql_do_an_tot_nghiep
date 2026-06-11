import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';

import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  AdminDashboardBloc() : super(AdminDashboardInitial()) {
    on<LoadAdminDashboardStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(
    LoadAdminDashboardStats event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(AdminDashboardLoading());

    try {
      // 1. CHUẨN BỊ GIỜ FAKE
      String currentTimeStr = TimeManager.now().toString().split('.').first;
      String encodedTime = Uri.encodeComponent(currentTimeStr);

      // 2. GỌI API THÔNG BÁO CỦA ADMIN (Vừa lấy chấm đỏ, vừa đẻ thông báo)
      final url = Uri.parse(
        "${AppUrls.baseUrl}/api/notifications/get_notifications.php?user_id=ADMIN&role=ADMIN&client_time=$encodedTime",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool unreadStatus = false;

        if (data['status'] == 'success') {
          unreadStatus = data['has_unread'] == true || data['has_unread'] == 1;
        }

        // 3. TRẢ KẾT QUẢ VỀ CHO GIAO DIỆN (UI)
        emit(AdminDashboardLoaded(hasUnread: unreadStatus));
      } else {
        emit(AdminDashboardError("Lỗi máy chủ: ${response.statusCode}"));
      }
    } catch (e) {
      emit(AdminDashboardError("Lỗi hệ thống: ${e.toString()}"));
    }
  }
}

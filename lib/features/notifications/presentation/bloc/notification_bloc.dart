import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/data/model/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      // 💡 LẤY GIỜ FAKE VÀ MÃ HÓA URL
      String currentTimeStr = TimeManager.now().toString().split('.').first;
      String encodedTime = Uri.encodeComponent(currentTimeStr);

      // 💡 ĐÃ SỬA LẠI ĐƯỜNG DẪN CHUẨN XÁC THEO CẤU TRÚC THƯ MỤC
      final url = Uri.parse(
        "${AppUrls.baseUrl}/api/notifications/get_notifications.php?user_id=${event.userId}&role=${event.role}&client_time=$encodedTime",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> listJson = data['data'];
          List<AppNotification> notifications = listJson
              .map((json) => AppNotification.fromJson(json))
              .toList();

          emit(NotificationLoaded(notifications));
        } else {
          emit(NotificationError(data['message'] ?? "Lỗi lấy dữ liệu"));
        }
      } else {
        emit(NotificationError("Lỗi kết nối máy chủ: ${response.statusCode}"));
      }
    } catch (e) {
      emit(NotificationError("Lỗi hệ thống: ${e.toString()}"));
    }
  }
}

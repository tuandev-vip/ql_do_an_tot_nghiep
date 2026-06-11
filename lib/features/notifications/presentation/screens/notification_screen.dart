import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/data/model/notification_model.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/bloc/notification_event.dart';
import 'package:ql_do_an_tot_nghiep/features/notifications/presentation/bloc/notification_state.dart';
// 💡 NHỚ IMPORT FILE TimeManager CỦA ÔNG VÀO ĐÂY

class NotificationScreen extends StatefulWidget {
  final String userId;
  final String role;

  const NotificationScreen({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Vừa vào màn hình là gọi API lấy thông báo liền
    context.read<NotificationBloc>().add(
      LoadNotifications(userId: widget.userId, role: widget.role),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "THÔNG BÁO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          } else if (state is NotificationError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            return _buildNotificationList(state.notifications);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "Bạn chưa có thông báo nào",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<AppNotification> notifications) {
    // 💡 Lấy mốc thời gian Fake để chia danh sách
    DateTime currentFakeTime = TimeManager.now();

    List<AppNotification> todayList = [];
    List<AppNotification> earlierList = [];

    for (var noti in notifications) {
      if (noti.createdAt.year == currentFakeTime.year &&
          noti.createdAt.month == currentFakeTime.month &&
          noti.createdAt.day == currentFakeTime.day) {
        todayList.add(noti);
      } else {
        earlierList.add(noti);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (todayList.isNotEmpty) ...[
          const Text(
            "Hôm nay",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...todayList.map((noti) => _buildNotificationCard(noti)),
          const SizedBox(height: 16),
        ],
        if (earlierList.isNotEmpty) ...[
          const Text(
            "Trước đó",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...earlierList.map((noti) => _buildNotificationCard(noti)),
        ],
      ],
    );
  }

  Widget _buildNotificationCard(AppNotification noti) {
    // 💡 BẮT MÀU VÀ ICON THEO TYPE TỪ DATABASE
    Color iconColor = Colors.blue;
    Color bgColor = Colors.blue.withOpacity(0.1);
    IconData iconShape = Icons.notifications_none_rounded;
    Color borderColor = Colors.transparent;

    if (noti.type == 'ERROR') {
      iconColor = Colors.redAccent;
      bgColor = Colors.redAccent.withOpacity(0.1);
      iconShape = Icons.error_outline;
      borderColor = Colors.redAccent.withOpacity(0.3);
    } else if (noti.type == 'WARNING') {
      iconColor = Colors.orange;
      bgColor = Colors.orange.withOpacity(0.1);
      iconShape = Icons.warning_amber_rounded;
    } else if (noti.type == 'SUCCESS') {
      iconColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
      iconShape = Icons.check_circle_outline;
      borderColor = Colors.green.withOpacity(
        0.3,
      ); // Giống viền thẻ "GV đã duyệt" trong Figma
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: noti.isRead
            ? Colors.white
            : const Color(0xFFF0F5FA), // Chưa đọc thì nền hơi xanh nhẹ
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor != Colors.transparent
              ? borderColor
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(iconShape, color: iconColor, size: 24),
        ),
        title: Text(
          noti.title,
          style: TextStyle(
            fontWeight: noti.isRead ? FontWeight.w600 : FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              noti.content,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(noti.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 💡 HÀM TÍNH THỜI GIAN "X giờ trước" DỰA VÀO FAKE TIME
  String _getTimeAgo(DateTime createdAt) {
    Duration diff = TimeManager.now().difference(createdAt);
    if (diff.inDays > 0) return "${diff.inDays} ngày trước";
    if (diff.inHours > 0) return "${diff.inHours} giờ trước";
    if (diff.inMinutes > 0) return "${diff.inMinutes} phút trước";
    return "Vừa xong";
  }
}

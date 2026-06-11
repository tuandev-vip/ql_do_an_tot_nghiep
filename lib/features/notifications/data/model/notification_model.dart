class AppNotification {
  final String id;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['noti_id'].toString(), // Tên cột trong DB của ông
      title: json['title'] ?? 'Thông báo',
      content: json['content'] ?? '',
      type: json['type'] ?? 'INFO',
      isRead: json['is_read'] == 1 || json['is_read'] == '1',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

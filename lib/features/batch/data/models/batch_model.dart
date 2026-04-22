class BatchModel {
  final String batchId;
  final String batchName;
  final String templateId;
  final String startDate;
  final int isClosed;

  // Dùng Map để chứa tất cả các mốc deadline từ DB
  final Map<String, String> deadlines;

  BatchModel({
    required this.batchId,
    required this.batchName,
    required this.startDate,
    required this.isClosed,
    required this.templateId,
    required this.deadlines,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchId: json['batch_id'] ?? '',
      batchName: json['batch_name'] ?? '',
      startDate: json['start_date'] ?? '',
      templateId: json['template_id'] ?? '',
      // Chuyển đổi is_closed sang kiểu int an toàn
      isClosed: int.tryParse(json['is_closed'].toString()) ?? 0,

      // Map toàn bộ 18+ mốc thời gian khớp với file create_batch.php
      deadlines: {
        "Đăng ký Giảng viên": json['reg_advisor_deadline'] ?? '',
        "Nộp đề cương": json['outline_deadline'] ?? '',
        "Báo cáo Tuần 1": json['report_w1_deadline'] ?? '',
        "Báo cáo Tuần 2": json['report_w2_deadline'] ?? '',
        "Báo cáo Tuần 3": json['report_w3_deadline'] ?? '',
        "Báo cáo Tuần 4": json['report_w4_deadline'] ?? '',
        "Báo cáo Tuần 5": json['report_w5_deadline'] ?? '',
        "Báo cáo Tuần 6": json['report_w6_deadline'] ?? '',
        "Báo cáo Tuần 7": json['report_w7_deadline'] ?? '',
        "Báo cáo Tuần 8": json['report_w8_deadline'] ?? '',
        "Báo cáo Tuần 9": json['report_w9_deadline'] ?? '',
        "Báo cáo Tuần 10": json['report_w10_deadline'] ?? '',
        "Hạn nhập điểm": json['final_grade_deadline'] ?? '',
        "Tạo Hội đồng cơ sở": json['council_cs_create_deadline'] ?? '',
        "Phân Hội đồng cơ sở": json['council_cs_assign_deadline'] ?? '',
        "Tạo Hội đồng trường": json['council_tr_create_deadline'] ?? '',
        "Phân Hội đồng trường": json['council_tr_assign_deadline'] ?? '',
        "Hạn Đóng đợt (Hệ thống)": json['close_date'] ?? '',
      },
    );
  }

  // Hàm tiện ích để lấy nhanh một deadline theo key
  String getDeadline(String milestone) => deadlines[milestone] ?? '';
}

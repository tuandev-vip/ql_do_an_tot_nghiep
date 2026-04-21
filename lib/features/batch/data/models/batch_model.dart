class BatchModel {
  final String batchId;
  final String batchName;
  final String templateId;
  final String startDate;
  final String advisorRegDeadline;
  final String councilTrAssignDeadline;
  final int isClosed;

  BatchModel({
    required this.batchId,
    required this.batchName,
    required this.startDate,
    required this.isClosed,
    required this.advisorRegDeadline,
    required this.councilTrAssignDeadline,
    required this.templateId,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchId: json['batch_id'] ?? '',
      batchName: json['batch_name'] ?? '',
      startDate: json['start_date'] ?? '',
      templateId: json['template_id'] ?? '',
      advisorRegDeadline: json['advisor_reg_deadline'] ?? '',
      councilTrAssignDeadline: json['council_tr_assign_deadline'] ?? '',
      isClosed: int.parse(json['is_closed'].toString()),
    );
  }
}

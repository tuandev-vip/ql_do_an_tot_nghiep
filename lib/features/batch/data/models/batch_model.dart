class BatchModel {
  final String batchId;
  final String batchName;
  final String startDate;
  final int isClosed;

  BatchModel({
    required this.batchId,
    required this.batchName,
    required this.startDate,
    required this.isClosed,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchId: json['batch_id'] ?? '',
      batchName: json['batch_name'] ?? '',
      startDate: json['start_date'] ?? '',
      isClosed: int.parse(json['is_closed'].toString()),
    );
  }
}

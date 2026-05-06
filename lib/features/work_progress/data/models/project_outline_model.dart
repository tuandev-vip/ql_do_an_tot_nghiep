class ProjectOutlineModel {
  final String topicDirection;
  final String topicName;
  final String outlineUrl;
  final String? deadline;

  ProjectOutlineModel({
    required this.topicDirection,
    required this.topicName,
    required this.outlineUrl,
    this.deadline,
  });

  factory ProjectOutlineModel.fromJson(Map<String, dynamic> json) {
    return ProjectOutlineModel(
      topicDirection: json['topic_direction'] ?? '',
      topicName: json['topic_name'] ?? '',
      outlineUrl: json['outline_url'] ?? '',
      deadline: json['deadline'],
    );
  }
}

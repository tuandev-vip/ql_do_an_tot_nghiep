class ProjectOutlineModel {
  final String topicDirection;
  final String topicName;
  final String outlineUrl;

  ProjectOutlineModel({
    required this.topicDirection,
    required this.topicName,
    required this.outlineUrl,
  });

  factory ProjectOutlineModel.fromJson(Map<String, dynamic> json) {
    return ProjectOutlineModel(
      topicDirection: json['topic_direction'] ?? '',
      topicName: json['topic_name'] ?? '',
      outlineUrl: json['outline_url'] ?? '',
    );
  }
}

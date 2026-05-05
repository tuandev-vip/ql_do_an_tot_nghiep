abstract class ProjectOutlineEvent {}

class FetchProjectOutline extends ProjectOutlineEvent {
  final String studentId;
  FetchProjectOutline(this.studentId);
}

class UpdateProjectOutline extends ProjectOutlineEvent {
  final String studentId;
  final String topicDirection;
  final String topicName;
  final String? filePath; // Dùng cho máy ảo / Điện thoại Android
  final List<int>? fileBytes; // Dùng cho trình duyệt Web
  final String? fileName; // Tên file để gửi lên Server

  UpdateProjectOutline({
    required this.studentId,
    required this.topicDirection,
    required this.topicName,
    this.filePath,
    this.fileBytes,
    this.fileName,
  });
}

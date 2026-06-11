abstract class TbmDashboardState {}

class TbmDashboardInitial extends TbmDashboardState {}

class TbmDashboardLoading extends TbmDashboardState {}

class TbmDashboardLoaded extends TbmDashboardState {
  final int totalStudents;
  final int totalTeachers;
  final int noAdvisor;
  final int missingMembers;
  final bool hasBatch; // 💡 Nhận diện xem có đợt đồ án không

  // 💡 THÊM 2 BIẾN MỐC THỜI GIAN ĐỂ CHẶN NÚT TRÊN UI
  final DateTime? outlineDeadline;
  final DateTime? reportW10Deadline;

  final bool isAILoading;
  final String? aiSummary;
  final String? aiError;

  TbmDashboardLoaded({
    required this.totalStudents,
    required this.totalTeachers,
    required this.noAdvisor,
    required this.missingMembers,
    required this.hasBatch,
    this.outlineDeadline,
    this.reportW10Deadline,
    this.isAILoading = false,
    this.aiSummary,
    this.aiError,
  });

  TbmDashboardLoaded copyWith({
    int? totalStudents,
    int? totalTeachers,
    int? noAdvisor,
    int? missingMembers,
    bool? hasBatch,
    DateTime? outlineDeadline,
    DateTime? reportW10Deadline,
    bool? isAILoading,
    String? aiSummary,
    String? aiError,
  }) {
    return TbmDashboardLoaded(
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      noAdvisor: noAdvisor ?? this.noAdvisor,
      missingMembers: missingMembers ?? this.missingMembers,
      hasBatch: hasBatch ?? this.hasBatch,
      outlineDeadline: outlineDeadline ?? this.outlineDeadline,
      reportW10Deadline: reportW10Deadline ?? this.reportW10Deadline,
      isAILoading: isAILoading ?? this.isAILoading,
      aiSummary: aiSummary ?? this.aiSummary,
      aiError: aiError,
    );
  }
}

class TbmDashboardError extends TbmDashboardState {
  final String message;
  TbmDashboardError(this.message);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/student_progress/data/repositories/student_report_repository.dart';
import '../../data/models/weekly_report_model.dart';

import 'student_report_event.dart';
import 'student_report_state.dart';

class StudentReportBloc extends Bloc<StudentReportEvent, StudentReportState> {
  final StudentReportRepository _repository = StudentReportRepository();

  StudentReportBloc() : super(ReportInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<SelectWeekEvent>(_onSelectWeek);
    // ĐĂNG KÝ SỰ KIỆN NỘP BÁO CÁO Ở ĐÂY
    on<SubmitReportEvent>(_onSubmitReport);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<StudentReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final result = await _repository.fetchStudentReports(event.studentId);

      final bool hasActiveBatch = result['hasActiveBatch'];
      final Map<int, WeeklyReportModel> reports = result['reports'];

      emit(
        ReportLoaded(
          reports: reports,
          selectedWeek: 1,
          hasActiveBatch: hasActiveBatch,
        ),
      );
    } catch (e) {
      emit(ReportError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  // HÀM XỬ LÝ NỘP BÁO CÁO
  Future<void> _onSubmitReport(
    SubmitReportEvent event,
    Emitter<StudentReportState> emit,
  ) async {
    // Lưu lại tuần đang chọn để sau khi load lại không bị nhảy về tuần 1
    int currentWeek = 1;
    if (state is ReportLoaded) {
      currentWeek = (state as ReportLoaded).selectedWeek;
    }

    emit(ReportLoading()); // Hiển thị loading khi đang upload

    try {
      // Gọi repository với đầy đủ thông tin để PHP đổi tên file
      await _repository.uploadReport(
        studentId: event.studentId,
        studentName: event.studentName,
        weekNum: event.weekNum,
        filePath: event.filePath,
      );

      // SAU KHI UPLOAD THÀNH CÔNG: Tải lại dữ liệu để cập nhật UI
      final result = await _repository.fetchStudentReports(event.studentId);

      emit(
        ReportLoaded(
          reports: result['reports'],
          selectedWeek: currentWeek, // Giữ nguyên tuần người dùng đang xem
          hasActiveBatch: result['hasActiveBatch'],
        ),
      );
    } catch (e) {
      emit(ReportError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  void _onSelectWeek(SelectWeekEvent event, Emitter<StudentReportState> emit) {
    if (state is ReportLoaded) {
      final currentState = state as ReportLoaded;
      emit(
        ReportLoaded(
          reports: currentState.reports,
          selectedWeek: event.selectedWeek,
          hasActiveBatch: currentState.hasActiveBatch,
        ),
      );
    }
  }
}

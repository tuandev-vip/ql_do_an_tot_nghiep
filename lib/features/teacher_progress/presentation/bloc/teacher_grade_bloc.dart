import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_urls.dart';
import 'teacher_grade_event.dart';
import 'teacher_grade_state.dart';
import '../../../../core/untils/time_manager.dart';

class TeacherGradeBloc extends Bloc<TeacherGradeEvent, TeacherGradeState> {
  TeacherGradeBloc() : super(TeacherGradeInitial()) {
    on<FetchGradeInfo>(_onFetchGradeInfo);
    on<SubmitTeacherGrade>(_onSubmitTeacherGrade);
  }

  Future<void> _onFetchGradeInfo(
    FetchGradeInfo event,
    Emitter<TeacherGradeState> emit,
  ) async {
    emit(TeacherGradeLoading());
    try {
      // 💡 LẤY FAKE TIME ĐỔI RA GIÂY (Chuẩn Unix Timestamp cho PHP)
      int fakeTime = TimeManager.now().millisecondsSinceEpoch ~/ 1000;

      // 💡 GẮN THÊM &fake_time VÀO API
      final response = await http.get(
        Uri.parse(
          "${AppUrls.getStudentGrade}?student_id=${event.studentId}&fake_time=$fakeTime",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          double? scoreVal;
          if (data['score'] != null && data['score'].toString() != "0") {
            scoreVal = double.tryParse(data['score'].toString());
          }
          emit(
            TeacherGradeLoaded(
              timeStatus: data['time_status'],
              openTime: data['open_time'],
              closeTime: data['close_time'],
              score: scoreVal,
            ),
          );
        } else {
          // Bắt các mã lỗi từ PHP ném về
          if (data['message'] == "NO_BATCH") {
            emit(TeacherGradeError("Sinh viên chưa có đợt đồ án."));
          } else if (data['message'] == "NO_OUTLINE") {
            emit(
              TeacherGradeError(
                "Vui lòng cập nhật đề cương trước khi chấm điểm.",
              ),
            );
          } else {
            emit(TeacherGradeError(data['message']));
          }
        }
      } else {
        emit(TeacherGradeError("Lỗi máy chủ: ${response.statusCode}"));
      }
    } catch (e) {
      emit(TeacherGradeError("Lỗi kết nối: $e"));
    }
  }

  Future<void> _onSubmitTeacherGrade(
    SubmitTeacherGrade event,
    Emitter<TeacherGradeState> emit,
  ) async {
    emit(TeacherGradeLoading()); // Hiện loading khi đang gửi API
    try {
      final response = await http.post(
        Uri.parse(AppUrls.updateStudentGrade),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "student_id": event.studentId,
          "score": event.score,
        }),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        // Nếu thành công thì bắn state success để UI hiện thông báo
        emit(TeacherGradeUpdateSuccess("Chốt điểm thành công!"));

        // Gọi lại Event fetch để load lại giao diện điểm mới nhất
        add(FetchGradeInfo(event.studentId));
      } else {
        emit(TeacherGradeError("Lỗi: ${data['message']}"));
      }
    } catch (e) {
      emit(TeacherGradeError("Lỗi hệ thống: $e"));
    }
  }
}

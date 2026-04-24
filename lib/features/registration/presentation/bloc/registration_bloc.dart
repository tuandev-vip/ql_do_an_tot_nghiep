import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/constants/app_urls.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';
import 'dart:convert';
import 'registration_event.dart';
import 'registration_state.dart';
import '../../../user/data/models/teacher_model.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  // BỎ final để có thể cập nhật lại danh sách gốc
  List<TeacherModel> _allTeachers = [];

  RegistrationBloc() : super(RegistrationInitial()) {
    // 1. Xử lý lấy danh sách giảng viên & Kiểm tra thời hạn
    on<FetchTeachersEvent>((event, emit) async {
      emit(RegistrationLoading());
      try {
        // 1. Lấy thời gian giả từ TimeManager để test mode
        String logicalNow = TimeManager.now().toIso8601String();

        // 2. Kiểm tra trạng thái thời hạn trước
        final statusRes = await http.get(
          Uri.parse("${AppUrls.urlCheckRegStatus}?fake_date=$logicalNow"),
        );
        print("Check Status Response: ${statusRes.body}");
        if (statusRes.statusCode == 200) {
          final statusData = json.decode(statusRes.body);

          // Nếu PHP trả về lỗi (ví dụ: Không tìm thấy đợt nào ACTIVE)
          if (statusData['status'] == 'error') {
            emit(
              RegistrationError(
                statusData['message'] ?? "Không có đợt nào đang mở",
                [],
              ),
            );
            return;
          }

          if (statusData['is_expired'] == true) {
            emit(
              RegistrationExpired(
                statusData['batch_name'],
                statusData['deadline_date'],
              ),
            );
            return;
          }
        }

        // 3. Nếu còn hạn: Tải danh sách giảng viên
        final response = await http.get(
          Uri.parse(
            "${AppUrls.urlFetchTeachers}?student_id=${event.studentId}",
          ),
        );
        print("Dữ liệu Server trả về: ${response.body}");
        if (response.statusCode == 200) {
          // Dùng dynamic để hứng dữ liệu vì chưa biết là List hay Map
          final dynamic decodedData = json.decode(response.body);

          // TRƯỜNG HỢP 1: Server trả về lỗi (Map)
          if (decodedData is Map && decodedData['status'] == 'error') {
            emit(RegistrationError(decodedData['message'], []));
            return;
          }

          // TRƯỜNG HỢP 2: Server trả về danh sách (List)
          if (decodedData is List) {
            _allTeachers = decodedData
                .map((j) => TeacherModel.fromJson(j))
                .toList();
            emit(TeachersLoaded(_allTeachers));
          } else {
            emit(RegistrationError("Dữ liệu không hợp lệ", []));
          }
        } else {
          emit(RegistrationError("Lỗi Server: ${response.statusCode}", []));
        }
      } catch (e) {
        // In lỗi ra console để ông dễ debug
        print("Lỗi RegistrationBloc: $e");
        emit(RegistrationError("Lỗi kết nối hệ thống!", []));
      }
    });
    // 2. Xử lý tìm kiếm
    on<SearchTeacherEvent>((event, emit) {
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        emit(TeachersLoaded(_allTeachers));
      } else {
        // Lúc này _allTeachers đã có dữ liệu nên lọc sẽ ra kết quả
        final filtered = _allTeachers.where((teacher) {
          return teacher.fullName.toLowerCase().contains(query) ||
              teacher.teacherCode.toLowerCase().contains(query);
        }).toList();
        emit(TeachersLoaded(filtered));
      }
    });

    // Tìm đến đoạn on<SubmitRegistrationEvent>...
    on<SubmitRegistrationEvent>((event, emit) async {
      try {
        final response = await http.post(
          Uri.parse(AppUrls.urlSubmitRegistrationTeachers),
          body: {
            'teacher_id': event.teacherId,
            'topic_direction': event.topicDirection,
            'student_id': event.studentId,
          },
        );

        if (response.statusCode == 200) {
          final resData = json.decode(response.body);

          // SỬA Ở ĐÂY: Kiểm tra ['status'] == 'success' thay vì ['success'] == true
          if (resData['status'] == 'success') {
            emit(
              RegistrationSuccess(
                resData['message'],
                event.teacherId,
                _allTeachers,
              ),
            );
          } else {
            emit(
              RegistrationError(
                resData['message'] ?? "Đăng ký thất bại",
                _allTeachers,
              ),
            );
          }
        } else {
          emit(RegistrationError("Lỗi kết nối Server", _allTeachers));
        }
      } catch (e) {
        emit(RegistrationError("Lỗi hệ thống: $e", _allTeachers));
      }
    });
  }
}

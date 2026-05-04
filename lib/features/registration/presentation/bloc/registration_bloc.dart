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
        // --- BƯỚC 1: LUÔN TẢI DANH SÁCH GIẢNG VIÊN TRƯỚC ---
        final response = await http.get(
          Uri.parse(
            "${AppUrls.urlFetchTeachers}?student_id=${event.studentId}",
          ),
        );
        print("Dữ liệu Server trả về: ${response.body}");

        if (response.statusCode == 200) {
          final dynamic decodedData = json.decode(response.body);
          if (decodedData is Map && decodedData['status'] == 'error') {
            emit(RegistrationError(decodedData['message'], []));
            return;
          }
          if (decodedData is List) {
            // Lưu dữ liệu vào biến toàn cục của Bloc
            _allTeachers = decodedData
                .map((j) => TeacherModel.fromJson(j))
                .toList();
          } else {
            emit(RegistrationError("Dữ liệu không hợp lệ", []));
            return;
          }
        } else {
          emit(RegistrationError("Lỗi Server: ${response.statusCode}", []));
          return;
        }

        // --- BƯỚC 2: KIỂM TRA TRẠNG THÁI THỜI HẠN SAU ---
        String logicalNow = TimeManager.now().toIso8601String();
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
                _allTeachers,
              ),
            );
            return;
          }

          // NẾU HẾT HẠN: Bắn ra trạng thái Expired KÈM THEO DANH SÁCH _allTeachers
          if (statusData['is_expired'] == true) {
            emit(
              RegistrationExpired(
                statusData['batch_name'] ?? "Đợt đồ án hiện tại",
                statusData['deadline_date'] ?? "Chưa xác định",
                _allTeachers, // <-- Nhờ có cái này, UI mới check được ai đã APPROVED
              ),
            );
            return;
          }
        }

        // --- BƯỚC 3: NẾU CÒN HẠN VÀ KHÔNG LỖI -> HIỂN THỊ BÌNH THƯỜNG ---
        emit(TeachersLoaded(_allTeachers));
      } catch (e) {
        print("Lỗi RegistrationBloc: $e");
        emit(RegistrationError("Lỗi kết nối hệ thống!", _allTeachers));
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

    // 1. Logic lấy danh sách SV cho Giảng viên (2 Tab)
    on<FetchAdvisorStudentsEvent>((event, emit) async {
      emit(RegistrationLoading());
      try {
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/teacher/get_pending_registrations.php?teacher_id=${event.teacherId}",
          ),
        );

        if (response.statusCode == 200) {
          // Bảo vệ: Nếu PHP trả về lỗi HTML <br />, json.decode sẽ không làm sập app
          final dynamic decodedData = json.decode(response.body);

          if (decodedData is List) {
            // Lọc ra SV chờ duyệt và SV đã duyệt ngay tại Bloc để UI nhàn hơn
            final pending = decodedData
                .where((s) => s['status'] == 'PENDING')
                .toList();
            final approved = decodedData
                .where((s) => s['status'] == 'APPROVED')
                .toList();
            emit(AdvisorStudentsLoaded(pending, approved));
          } else {
            emit(RegistrationError("Dữ liệu không đúng định dạng", []));
          }
        }
      } catch (e) {
        emit(RegistrationError("Lỗi hệ thống: $e", []));
      }
    });

    // 2. Logic cập nhật trạng thái Duyệt/Từ chối
    on<UpdateStudentStatusEvent>((event, emit) async {
      try {
        final response = await http.post(
          Uri.parse("${AppUrls.baseUrl}/api/teacher/approve_registration.php"),
          // Đảm bảo ép kiểu dữ liệu gửi lên là JSON
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'reg_id': event.regId,
            'status': event.status,
            'teacher_id':
                event.teacherId, // Truyền thêm để load lại data nếu cần
          }),
        );

        if (response.statusCode == 200) {
          final resData = json.decode(response.body);

          // KIỂM TRA TRẠNG THÁI TRONG JSON TRẢ VỀ
          if (resData['status'] == 'success') {
            // Nếu thành công: Load lại danh sách để cập nhật UI
            add(FetchAdvisorStudentsEvent(event.teacherId));
          } else {
            // NẾU LỖI (Ví dụ: Đã đủ 2/2): Bắn ra trạng thái Error để UI hiện SnackBar
            emit(
              RegistrationError(resData['message'] ?? "Không thể cập nhật", []),
            );

            //Load lại danh sách cũ sau khi cập nhật ui
            add(FetchAdvisorStudentsEvent(event.teacherId));
          }
        } else {
          emit(
            RegistrationError("Lỗi kết nối Server: ${response.statusCode}", []),
          );
        }
      } catch (e) {
        print("Lỗi khi cập nhật trạng thái: $e");
        emit(RegistrationError("Lỗi hệ thống: $e", []));
      }
    });
  }
}

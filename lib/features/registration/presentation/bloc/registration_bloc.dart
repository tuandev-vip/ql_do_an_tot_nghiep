import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registration_event.dart';
import 'registration_state.dart';
import '../../../user/data/models/teacher_model.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  // BỎ final để có thể cập nhật lại danh sách gốc
  List<TeacherModel> _allTeachers = [];

  RegistrationBloc() : super(RegistrationInitial()) {
    // 1. Xử lý lấy danh sách giảng viên
    on<FetchTeachersEvent>((event, emit) async {
      emit(RegistrationLoading());
      try {
        final response = await http.get(
          Uri.parse("http://192.168.1.109/ql_do_an_api/admin/get_teachers.php"),
        );
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          // CẬP NHẬT danh sách gốc để phục vụ tìm kiếm
          _allTeachers = data.map((j) => TeacherModel.fromJson(j)).toList();

          emit(TeachersLoaded(_allTeachers));
        }
      } catch (e) {
        emit(RegistrationError("Không thể lấy danh sách giảng viên"));
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
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registration_event.dart';
import 'registration_state.dart';
import '../../../user/data/models/teacher_model.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
    // Xử lý lấy danh sách giảng viên
    on<FetchTeachersEvent>((event, emit) async {
      emit(RegistrationLoading());
      try {
        final response = await http.get(
          Uri.parse("http://192.168.1.109/ql_do_an_api/admin/get_teachers.php"),
        );
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          final teachers = data.map((j) => TeacherModel.fromJson(j)).toList();
          emit(TeachersLoaded(teachers));
        }
      } catch (e) {
        emit(RegistrationError("Không thể lấy danh sách giảng viên"));
      }
    });

    // Phần SubmitRegistration sẽ làm ở bước tiếp theo Tuấn nhé!
  }
}

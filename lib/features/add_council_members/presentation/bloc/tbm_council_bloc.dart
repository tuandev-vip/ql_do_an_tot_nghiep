import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tbm_council_event.dart';
import 'tbm_council_state.dart';
import '../../../../core/constants/app_urls.dart';
// 💡 1. BẮT BUỘC PHẢI IMPORT TIME_MANAGER VÀO ĐÂY
import '../../../../core/untils/time_manager.dart';

class TbmCouncilBloc extends Bloc<TbmCouncilEvent, TbmCouncilState> {
  TbmCouncilBloc() : super(TbmCouncilInitial()) {
    on<FetchTbmCouncilsEvent>((event, emit) async {
      emit(TbmCouncilLoading());

      try {
        // 💡 2. LẤY GIỜ TỪ CỖ MÁY THỜI GIAN
        String fakeTime = (TimeManager.now().millisecondsSinceEpoch ~/ 1000)
            .toString();

        String myDeptCode = event.deptCode;
        String isSchool = event.isSchoolLevel ? 'true' : 'false';

        // 💡 3. NHÉT FAKE_TIME VÀO URL GỌI API
        final response = await http.get(
          Uri.parse(
            "${AppUrls.baseUrl}/api/council/get_tbm_councils.php?dept_code=$myDeptCode&is_school=$isSchool&fake_time=$fakeTime",
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            emit(
              TbmCouncilLoaded(
                councils: data['councils'] ?? [],
                assignTimeStatus: data['assign_time_status'] ?? "OPEN",
              ),
            );
          } else {
            emit(TbmCouncilError(data['message'] ?? "Lỗi dữ liệu"));
          }
        } else {
          emit(TbmCouncilError("Lỗi máy chủ: ${response.statusCode}"));
        }
      } catch (e) {
        emit(TbmCouncilError("Lỗi hệ thống không thể kết nối."));
      }
    });
  }
}

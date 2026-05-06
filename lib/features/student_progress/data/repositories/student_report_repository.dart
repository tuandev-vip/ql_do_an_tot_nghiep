import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/weekly_report_model.dart';

class StudentReportRepository {
  // 1. Hàm bổ trợ xóa dấu Tiếng Việt và khoảng trắng để tránh lỗi URL
  String _removeDiacritics(String str) {
    var withDia =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỵỷỹĐ';
    var withoutDia =
        'aaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiioooooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    // Thay khoảng trắng bằng dấu gạch dưới để tên file liền mạch
    return str.replaceAll(' ', '_');
  }

  Future<Map<String, dynamic>> fetchStudentReports(String studentId) async {
    final int currentTimestamp =
        TimeManager.now().millisecondsSinceEpoch ~/ 1000;

    final url = Uri.parse(
      '${AppUrls.getStudentReports}?student_id=$studentId&fake_time=$currentTimestamp',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          Map<int, WeeklyReportModel> reportsMap = {};

          if (data['reports'] != null) {
            Map<String, dynamic> reportsJson = data['reports'];
            reportsJson.forEach((key, value) {
              reportsMap[int.parse(key)] = WeeklyReportModel(
                week: value['week'],
                status: value['status'],
                deadline: value['deadline'],
                submitTime: value['submitTime'] ?? "",
                fileName: value['fileName'] ?? "",
                feedback: value['feedback'] ?? "",
              );
            });
          }

          return {
            "hasActiveBatch": data['hasActiveBatch'],
            "reports": reportsMap,
          };
        } else if (data['status'] == 'error' &&
            data['hasActiveBatch'] == false) {
          return {
            "hasActiveBatch": false,
            "reports": <int, WeeklyReportModel>{},
          };
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Lỗi kết nối server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tải dữ liệu tiến độ. Chi tiết: $e');
    }
  }

  // 2. Cập nhật hàm uploadReport nhận thêm Mã SV và Tên SV
  Future<String> uploadReport({
    required String studentId,
    required String studentName, // Thêm mới
    required int weekNum,
    required String filePath,
  }) async {
    final url = Uri.parse(AppUrls.submitReport);

    var request = http.MultipartRequest('POST', url);

    // Gửi các thông tin để PHP xử lý đổi tên file
    request.fields['student_id'] = studentId;
    request.fields['week_num'] = weekNum.toString();
    // Xóa dấu tên sinh viên trước khi gửi lên để đặt tên file an toàn
    request.fields['student_name'] = _removeDiacritics(studentName);

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    try {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return data['message'];
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception("Lỗi Server trả về không hợp lệ:\n${response.body}");
    }
  }
}

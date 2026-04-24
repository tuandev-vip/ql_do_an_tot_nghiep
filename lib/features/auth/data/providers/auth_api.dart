import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_urls.dart';

class AuthApi {
  final http.Client client;
  AuthApi({required this.client});

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Gửi yêu cầu POST đến file login.php trên XAMPP
      final response = await client.post(
        Uri.parse(AppUrls.urlLogin),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Lỗi kết nối Server: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Không thể kết nối XAMPP. Hãy kiểm tra IP và WiFi!",
      };
    }
  }
}

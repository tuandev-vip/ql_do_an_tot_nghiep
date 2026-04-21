class AppUrls {
  // Thay địa chỉ IP bằng IP máy tính của bạn khi dùng máy thật
  // Hoặc dùng 10.0.2.2 nếu dùng Android Emulator
  static const String baseUrl = "http://192.168.1.109/ql_do_an_api";

  // --- Auth Endpoints ---
  static const String login = "$baseUrl/auth/login.php";
  static const String logout = "$baseUrl/auth/logout.php";
  static const String changePassword = "$baseUrl/auth/change_password.php";
  static const String resetPasswordRequest = "$baseUrl/auth/reset_request.php";

  // --- Sau này thêm tới đâu, viết tới đó ---
  // static const String getStudentProjects = "$baseUrl/projects/get_list.php";
}

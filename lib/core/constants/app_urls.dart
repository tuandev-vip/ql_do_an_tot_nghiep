class AppUrls {
  // Thay địa chỉ IP bằng IP máy tính của bạn khi dùng máy thật
  // Hoặc dùng 10.0.2.2 nếu dùng Android Emulator
  static const String baseUrl = "http://192.168.1.109/ql_do_an_api";

  // --- Auth Endpoints ---
  static const String urlLogin = "$baseUrl/auth/login.php";
  static const String urlLogout = "$baseUrl/auth/logout.php";
  static const String urlChangePassword = "$baseUrl/auth/change_password.php";

  // --- Batch Endpoints ---
  static const String urlGetBatches = "$baseUrl/api/batch/get_batches.php";
  static const String urlCloseBatch = "$baseUrl/api/batch/close_batch.php";
  static const String urlCreateBatch = "$baseUrl/api/batch/create_batch.php";
  static const String urlUpdateBatch = "$baseUrl/api/batch/update_batch.php";
  static const String urlGetTeamplate = "$baseUrl/api/batch/get_templates.php";

  //--- regostration ---
  static const String urlFetchTeachers = "$baseUrl/student/get_teachers.php";
  static const String urlSubmitRegistrationTeachers =
      "$baseUrl/student/submit_registration.php";

  //--- regostration ---
  static const String urlFetchUsers = "$baseUrl/admin/get_users.php";
  static const String urlResetpassword = "$baseUrl/admin/reset_password.php";
}

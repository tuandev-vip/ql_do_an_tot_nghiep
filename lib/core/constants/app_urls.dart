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
  static const String urlCheckRegStatus =
      "$baseUrl/api/batch/check_registration_status.php";

  //--- regostration ---
  static const String urlFetchTeachers =
      "$baseUrl/api/student/get_teachers.php";
  static const String urlSubmitRegistrationTeachers =
      "$baseUrl/api/student/submit_registration.php";

  //--- regostration ---
  static const String urlFetchUsers = "$baseUrl/api/admin/get_users.php";
  static const String urlResetpassword =
      "$baseUrl/api/admin/reset_password.php";
}

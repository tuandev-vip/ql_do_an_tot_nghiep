import '../models/user_model.dart';
import '../providers/auth_api.dart';

class AuthRepository {
  final AuthApi api;
  AuthRepository({required this.api});

  Future<UserModel?> login(String username, String password) async {
    final result = await api.login(username, password);

    if (result['status'] == 'success') {
      // Nếu thành công, trả về UserModel được tạo từ JSON 'user'
      return UserModel.fromJson(result['user']);
    } else {
      // Nếu thất bại, bạn có thể quăng một lỗi hoặc trả về null
      throw Exception(result['message']);
    }
  }
}

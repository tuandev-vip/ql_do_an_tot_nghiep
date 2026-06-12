import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/auth/presentation/screens/main_wrapper.dart';
import 'package:ql_do_an_tot_nghiep/features/user/data/models/user_data_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 💡 1. BIẾN TRẠNG THÁI CHO MẮT XEM MẬT KHẨU
  bool _isObscure = true;

  // 💡 ĐƯỜNG DẪN ẢNH (Ông sửa lại đường dẫn này cho khớp với thư mục của ông nhé)
  final String bgImagePath = 'assets/images/background.png';
  final String logoPath = 'assets/images/logoICTU.png';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Làm trong suốt luôn thanh pin/sóng ở trên
        systemNavigationBarColor:
            Colors.transparent, // Làm trong suốt dải đen ở dưới
        systemNavigationBarIconBrightness:
            Brightness.dark, // Hiển thị nút vuốt màu tối cho dễ nhìn
      ),
    );

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainWrapper(
                  user: state.user,
                  userData: UserDataModel(
                    id: state.user.userId.toString(),
                    fullName: state.user.fullName,
                    role: state.user.role,
                    username: state.user.userCode,
                    isParticipating: true,
                  ),
                ),
              ),
            );
          }
        },
        // ... (Phần trên giữ nguyên)
        builder: (context, state) {
          return Stack(
            children: [
              // 💡 1. ẢNH NỀN PHỦ KÍN MÀN HÌNH
              Positioned.fill(
                child: Image.asset(
                  bgImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.blueAccent),
                ),
              ),
              // 💡 2. LỚP PHỦ MỜ ĐEN
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),

              // 💡 3. NỘI DUNG CHÍNH (Gồm Form + Chữ bên dưới)
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  // 🔥 DÙNG COLUMN BỌC CẢ FORM VÀ CHỮ LẠI ĐỂ NÓ NẰM ĐÚNG VỊ TRÍ
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- KHỐI FORM TRẮNG ---
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // LOGO ICTU
                            Image.asset(
                              logoPath,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.school,
                                    size: 80,
                                    color: Colors.blueAccent,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              "ĐĂNG NHẬP",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.blueAccent,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Ô nhập tài khoản
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: "Tên đăng nhập",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Ô nhập mật khẩu có Mắt thần
                            TextField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.blueAccent,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Nút Đăng nhập
                            ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                        LoginSubmitted(
                                          username: _usernameController.text,
                                          password: _passwordController.text,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "ĐĂNG NHẬP",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      // --- KẾT THÚC KHỐI FORM TRẮNG ---

                      // 💡 TEXT QUÊN MẬT KHẨU (Được chỉnh thành trắng xám)
                      const SizedBox(height: 30), // Cách form trắng ra 30px
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Nếu quên mật khẩu, vui lòng liên hệ với GVHD hoặc Văn phòng Khoa để được hỗ trợ.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors
                                .white70, // 🔥 Đổi thành màu trắng xám (mờ 70%)
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

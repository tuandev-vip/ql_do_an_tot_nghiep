import 'package:flutter/material.dart';
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
  // Controller để lấy dữ liệu từ ô nhập
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            // Hiện thông báo lỗi nếu đăng nhập thất bại
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
                  // 1. Giữ nguyên user cho phần Auth
                  user: state.user,

                  // 2. Map dữ liệu sang UserDataModel mà không cần sửa class
                  userData: UserDataModel(
                    // userId (int) bên Auth -> id (String) bên User
                    id: state.user.userId.toString(),
                    fullName: state.user.fullName,
                    role: state.user.role,
                    // userCode (Mã SV) bên Auth -> username bên User
                    username: state.user.userCode,
                    // Mặc định là true vì đã đăng nhập thành công
                    isParticipating: true,
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Đăng Nhập",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Ô nhập tài khoản
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Tên đăng nhập",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Ô nhập mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Ẩn mật khẩu
                  decoration: const InputDecoration(
                    labelText: "Mật khẩu",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                // Nút Đăng nhập
                ElevatedButton(
                  onPressed: state is AuthLoading
                      ? null // Vô hiệu hóa nút khi đang load
                      : () {
                          // Gửi sự kiện vào BLoC
                          context.read<AuthBloc>().add(
                            LoginSubmitted(
                              username: _usernameController.text,
                              password: _passwordController.text,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: state is AuthLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 16)),
                ),

                TextButton(
                  onPressed: () {
                    // Logic Quên mật khẩu sẽ làm sau
                  },
                  child: const Text("Quên mật khẩu?"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

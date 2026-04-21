// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // Khởi tạo GetIt
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Lấy AuthBloc đã đăng ký trong GetIt
      create: (context) => sl<AuthBloc>(),
      child: MaterialApp(
        title: 'Quản lý đồ án',
        routes: {'/login': (context) => const LoginScreen()},
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: const LoginScreen(), // Chạy màn hình Login đầu tiên
      ),
    );
  }
}

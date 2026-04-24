import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/service_locator.dart';
import 'package:ql_do_an_tot_nghiep/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/auth/presentation/screens/login_screen.dart';

// THÊM CÁC DÒNG IMPORT NÀY ĐỂ HẾT LỖI "isn't defined"
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/bloc/batch_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/bloc/batch_event.dart';
import 'package:ql_do_an_tot_nghiep/features/user/presentation/bloc/user_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/user/presentation/bloc/user_event.dart';
import 'package:ql_do_an_tot_nghiep/features/registration/presentation/bloc/registration_bloc.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // Khởi tạo GetIt
  runApp(
    // Bọc MultiBlocProvider ở ngoài cùng để tất cả màn hình đều dùng được
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<AuthBloc>(),
        ), // Lấy AuthBloc từ GetIt
        BlocProvider(create: (context) => BatchBloc()..add(LoadBatchesEvent())),
        BlocProvider(create: (context) => UserBloc()..add(FetchUsersEvent())),
        BlocProvider(create: (context) => RegistrationBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Không cần bọc thêm BlocProvider ở đây nữa vì đã có ở trên
    return MaterialApp(
      title: 'Quản lý đồ án',
      routes: {'/login': (context) => const LoginScreen()},
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

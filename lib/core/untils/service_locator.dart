// lib/core/utils/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:ql_do_an_tot_nghiep/features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/data/providers/auth_api.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. External: Đăng ký http Client
  sl.registerLazySingleton(() => http.Client());

  // 2. Providers
  sl.registerLazySingleton(() => AuthApi(client: sl()));

  // 3. Repositories
  sl.registerLazySingleton(() => AuthRepository(api: sl()));

  sl.registerFactory(() => AuthBloc(authRepository: sl()));
}

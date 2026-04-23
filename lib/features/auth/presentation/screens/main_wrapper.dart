import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/bloc/batch_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/bloc/batch_event.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/screens/batch_management_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../data/models/user_model.dart';
import '../profile/profile_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/user/presentation/bloc/user_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/user/presentation/bloc/user_event.dart';
// Thêm 3 dòng này Tuấn nhé
import 'package:ql_do_an_tot_nghiep/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/registration/presentation/screens/advisor_registration_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/user/data/models/user_data_model.dart'; // Đây là UserDataModel bên user

class _NavConfig {
  final BottomNavigationBarItem item;
  final Widget screen;
  _NavConfig({required this.item, required this.screen});
}

class MainWrapper extends StatefulWidget {
  final UserModel user;
  final UserDataModel userData;
  const MainWrapper({super.key, required this.user, required this.userData});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  List<_NavConfig> _buildNavigation() {
    List<_NavConfig> configs = [];

    // 1. TRANG CHỦ: Phân quyền Dashboard theo Role
    Widget homeScreen;
    switch (widget.user.role) {
      case 'DEAN':
        // Trưởng khoa thấy Dashboard có Cỗ máy thời gian
        homeScreen = const AdminDashboardScreen();
        break;
      case 'TBM':
        homeScreen = _buildPlaceholderScreen("Dashboard Trưởng bộ môn");
        break;
      case 'TEACHER':
        homeScreen = _buildPlaceholderScreen("Dashboard Giảng viên");
        break;
      case 'STUDENT':
        homeScreen = _buildPlaceholderScreen("Dashboard Sinh viên");
        break;
      default:
        homeScreen = _buildPlaceholderScreen("Trang chủ");
    }

    configs.add(
      _NavConfig(
        item: const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: "Trang chủ",
        ),
        screen: homeScreen,
      ),
    );

    // 2. LOGIC CHO SINH VIÊN (STUDENT)
    if (widget.user.role == 'STUDENT') {
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind_outlined),
            label: "ĐK GVHD",
          ),
          screen: AdvisorRegistrationScreen(studentId: widget.userData.id),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "Báo cáo",
          ),
          screen: _buildPlaceholderScreen("Nộp báo cáo tuần"),
        ),
      );
    }
    // 3. LOGIC CHO GIẢNG VIÊN (TEACHER)
    else if (widget.user.role == 'TEACHER') {
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            label: "Kiểm duyệt",
          ),
          screen: _buildPlaceholderScreen("Phê duyệt đề tài"),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            label: "Duyệt báo cáo",
          ),
          screen: _buildPlaceholderScreen("Chấm báo cáo tuần"),
        ),
      );
    }
    // 4. LOGIC CHO TRƯỞNG BỘ MÔN (TBM)
    else if (widget.user.role == 'TBM') {
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_outlined),
            label: "Phân GV",
          ),
          screen: _buildPlaceholderScreen("Phân Giảng viên hướng dẫn"),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: "Hội đồng",
          ),
          screen: _buildPlaceholderScreen("Quản lý Hội đồng cơ sở"),
        ),
      );
    }
    // 5. LOGIC CHO TRƯỞNG KHOA (DEAN)
    else if (widget.user.role == 'DEAN') {
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy_outlined),
            label: "Đợt đồ án",
          ),
          screen: const BatchManagementScreen(),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: "Thống kê",
          ),
          screen: _buildPlaceholderScreen("Thống kê toàn khoa"),
        ),
      );
    }

    // 6. TAB CÁ NHÂN (Luôn có cho tất cả mọi người)
    configs.add(
      _NavConfig(
        item: const BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: "Cá nhân",
        ),
        screen: ProfileScreen(user: widget.user),
      ),
    );

    return configs;
  }

  @override
  Widget build(BuildContext context) {
    final List<_NavConfig> navConfigs = _buildNavigation();

    // Reset index nếu role thay đổi để tránh lỗi index out of bounds
    if (_currentIndex >= navConfigs.length) {
      _currentIndex = 0;
    }

    return MultiBlocProvider(
      providers: [
        // 1. Giữ nguyên BatchBloc
        BlocProvider(create: (context) => BatchBloc()..add(LoadBatchesEvent())),
        // 2. THÊM UserBloc vào đây
        BlocProvider(create: (context) => UserBloc()..add(FetchUsersEvent())),
        //dang ky GVHD
        BlocProvider(create: (context) => RegistrationBloc()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: navConfigs.map((config) => config.screen).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2196F3),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          items: navConfigs.map((config) => config.item).toList(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Người dùng: ${widget.user.fullName}"),
            Text("Quyền hạn: ${widget.user.role}"),
          ],
        ),
      ),
    );
  }
}

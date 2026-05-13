import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/add_council_members/presentation/bloc/tbm_council_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/add_council_members/presentation/screens/tbm_council_management_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/auto_assignment/presentation/bloc/auto_assignment_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/auto_assignment/presentation/screens/auto_assignment_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/screens/batch_management_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/create_council/presentation/screens/council_management_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/registration/presentation/bloc/registration_event.dart';
import 'package:ql_do_an_tot_nghiep/features/registration/presentation/screens/advisor_requests_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/student_progress/presentation/screens/student_progress_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/work_progress/presentation/bloc/project_evaluation_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/work_progress/presentation/screens/project_evaluation_screen.dart';
import '../../data/models/user_model.dart';
import '../profile/profile_screen.dart';
// Thêm 3 dòng này Tuấn nhé
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
  late List<_NavConfig> _navConfigs;

  @override
  void initState() {
    super.initState();
    // KHỞI TẠO DANH SÁCH SCREEN Ở ĐÂY (Chỉ chạy 1 lần)
    _navConfigs = _buildNavigation();
  }

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
          screen: StudentProgressScreen(
            studentId: widget.userData.id,
            studentName: widget.user.fullName,
          ),
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
          screen: AdvisorRequestsScreen(teacherId: widget.userData.id),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            label: "QL đồ án",
          ),
          screen: BlocProvider(
            create: (context) => ProjectEvaluationBloc(),
            child: ProjectEvaluationScreen(teacherId: widget.userData.id),
          ),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            label: "Hội đồng",
          ),
          screen: _buildPlaceholderScreen("Hội đồng"),
        ),
      );
    }
    // 4. LOGIC CHO TRƯỞNG BỘ MÔN (TBM)
    else if (widget.user.role == 'TBM') {
      final String userDept = widget.user.deptId ?? "";
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_outlined),
            label: "Phân GV",
          ),
          screen: BlocProvider(
            create: (context) => AutoAssignmentBloc(),
            child: userDept.isNotEmpty
                ? AutoAssignmentScreen(
                    deptId: userDept,
                  ) // Truyền động theo User đăng nhập
                : const Center(child: Text("Tài khoản chưa được gán bộ môn!")),
          ),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: "Hội đồng",
          ),
          screen: BlocProvider(
            create: (context) => TbmCouncilBloc(),
            child: const TbmCouncilManagementScreen(),
          ),
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
            icon: Icon(Icons.person_2),
            label: "Hội đồng",
          ),
          screen: const CouncilManagementScreen(),
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
    // Reset index nếu role thay đổi để tránh lỗi index out of bounds

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navConfigs.map((config) => config.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // 1. Cập nhật index để chuyển màn hình như bình thường
          setState(() => _currentIndex = index);

          //  2. KIỂM TRA NẾU LÀ GIẢNG VIÊN VÀ NHẤN VÀO TAB KIỂM DUYỆT
          if (widget.user.role == 'TEACHER') {
            if (index == 1) {
              // Ép RegistrationBloc chạy lại lệnh lấy danh sách mới nhất
              context.read<RegistrationBloc>().add(
                FetchAdvisorStudentsEvent(widget.userData.id),
              );
            }
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        items: _navConfigs.map((config) => config.item).toList(),
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

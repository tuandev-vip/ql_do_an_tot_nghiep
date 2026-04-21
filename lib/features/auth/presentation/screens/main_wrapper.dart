import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../profile/profile_screen.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/screens/batch_management_screen.dart';

class _NavConfig {
  final BottomNavigationBarItem item;
  final Widget screen;
  _NavConfig({required this.item, required this.screen});
}

class MainWrapper extends StatefulWidget {
  final UserModel user;
  const MainWrapper({super.key, required this.user});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  List<_NavConfig> _buildNavigation() {
    List<_NavConfig> configs = [];

    // 1. LUÔN CÓ: Trang chủ (Dashboard) cho tất cả mọi người
    configs.add(
      _NavConfig(
        item: const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: "Trang chủ",
        ),
        screen: _buildPlaceholderScreen(
          widget.user.role == 'TBM'
              ? "Dashboard (Thống kê AI)"
              : "Màn hình Trang chủ",
        ),
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
          screen: _buildPlaceholderScreen("ĐK GVHD"),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "Báo cáo",
          ),
          screen: _buildPlaceholderScreen("Báo cáo"),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: "Hội đồng",
          ),
          screen: _buildPlaceholderScreen("Hội đồng"),
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
          screen: _buildPlaceholderScreen("Kiểm duyệt"),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            label: "Duyệt báo cáo",
          ),
          screen: _buildPlaceholderScreen("Duyệt báo cáo"),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: "Hội đồng",
          ),
          screen: _buildPlaceholderScreen("Hội đồng"),
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
          screen: _buildPlaceholderScreen("Phân GV"),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: "Phân hội đồng",
          ),
          screen: _buildPlaceholderScreen("Phân hội đồng"),
        ),
      );
    }
    // 5. LOGIC CHO TRƯỞNG KHOA (DEAN / ADMIN)
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
          screen: _buildPlaceholderScreen("Thống kê"),
        ),
      );
      configs.add(
        _NavConfig(
          item: const BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: "Hội đồng",
          ),
          screen: _buildPlaceholderScreen("Hội đồng"),
        ),
      );
    }

    // 6.  Cá nhân
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

    // Reset index nếu role thay đổi hoặc số lượng tab thay đổi để tránh crash
    if (_currentIndex >= navConfigs.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: navConfigs.map((config) => config.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type:
            BottomNavigationBarType.fixed, // Giữ icon cố định khi có nhiều tab
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        items: navConfigs.map((config) => config.item).toList(),
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("User: ${widget.user.fullName} (${widget.user.role})"),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/create_council/presentation/bloc/council_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/create_council/presentation/widgets/council_tab_view_card.dart';

class CouncilManagementScreen extends StatefulWidget {
  const CouncilManagementScreen({super.key});

  @override
  State<CouncilManagementScreen> createState() =>
      _CouncilManagementScreenState();
}

// 💡 Thêm SingleTickerProviderStateMixin để quản lý hiệu năng của Tab
class _CouncilManagementScreenState extends State<CouncilManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CouncilBloc _councilBloc;
  @override
  void initState() {
    super.initState();
    // 💡 Khởi tạo TabController thủ công, vsync: this giúp nó "ngủ" khi màn hình bị giấu
    _tabController = TabController(length: 2, vsync: this);
    _councilBloc = CouncilBloc();
  }

  @override
  void dispose() {
    _tabController.dispose(); // Hủy để giải phóng RAM khi thoát
    _councilBloc.close();
    super.dispose();
  }

  void _handleExport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tính năng xuất file đang phát triển!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _councilBloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          title: const Text(
            "QUẢN LÝ HỘI ĐỒNG",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF2196F3),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller:
                    _tabController, // 💡 Gắn controller thủ công vào đây
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blueAccent,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(text: "Cấp cơ sở"),
                  Tab(text: "Cấp trường"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController, // 💡 Gắn controller thủ công vào đây
          children: const [
            CouncilTabView(isSchoolLevel: false),
            CouncilTabView(isSchoolLevel: true),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "unique_council_btn",
          onPressed: () => _handleExport(context),
          backgroundColor: const Color(0xFFBDB76B),
          label: const Text(
            "Xuất file",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

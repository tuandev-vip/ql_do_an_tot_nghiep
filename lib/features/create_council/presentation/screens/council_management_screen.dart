import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/create_council/presentation/bloc/council_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/create_council/presentation/widgets/council_tab_view_card.dart';
import 'package:ql_do_an_tot_nghiep/features/create_council/presentation/widgets/council_school_tab_view_card.dart';

class CouncilManagementScreen extends StatefulWidget {
  const CouncilManagementScreen({super.key});

  @override
  State<CouncilManagementScreen> createState() =>
      _CouncilManagementScreenState();
}

class _CouncilManagementScreenState extends State<CouncilManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 💡 Đã xóa dòng khởi tạo _councilBloc chung ở đây
  }

  @override
  void dispose() {
    _tabController.dispose();
    // 💡 Đã xóa dòng close _councilBloc chung ở đây
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Đã xóa BlocProvider bọc ngoài Scaffold
    return Scaffold(
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
              controller: _tabController,
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
        controller: _tabController,
        children: [
          // 💡 CẤP CHO MỖI TAB 1 BLOC RIÊNG ĐỂ KHÔNG BỊ ĐÈ DỮ LIỆU
          BlocProvider(
            create: (context) => CouncilBloc(),
            child: const CouncilTabView(isSchoolLevel: false),
          ),
          BlocProvider(
            create: (context) => CouncilBloc(),
            child: const CouncilSchoolTabView(),
          ),
        ],
      ),
    );
  }
}

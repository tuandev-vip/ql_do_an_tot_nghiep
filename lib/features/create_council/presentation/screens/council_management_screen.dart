import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/create_council/presentation/bloc/council_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/create_council/presentation/widgets/council_tab_view_card.dart';
// 💡 Bắt buộc Import file Tab Cấp trường mới
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
  late CouncilBloc _councilBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _councilBloc = CouncilBloc();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _councilBloc.close();
    super.dispose();
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
          children: const [
            CouncilTabView(isSchoolLevel: false), // 💡 Tab Cơ sở
            CouncilSchoolTabView(), // 💡 Tab Cấp trường (File mới)
          ],
        ),
        // 💡 ĐÃ XÓA FLOATING ACTION BUTTON Ở ĐÂY
      ),
    );
  }
}

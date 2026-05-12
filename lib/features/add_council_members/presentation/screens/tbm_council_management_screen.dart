import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 Bắt buộc phải có thư viện này

import '../bloc/tbm_council_bloc.dart';
import '../bloc/tbm_council_event.dart';
import '../bloc/tbm_council_state.dart';
import '../bloc/tbm_council_detail_bloc.dart'; // 💡 Bắt buộc phải có
import '../widgets/tbm_council_card.dart';
import 'tbm_council_detail_screen.dart';

class TbmCouncilManagementScreen extends StatefulWidget {
  const TbmCouncilManagementScreen({super.key});

  @override
  State<TbmCouncilManagementScreen> createState() =>
      _TbmCouncilManagementScreenState();
}

class _TbmCouncilManagementScreenState extends State<TbmCouncilManagementScreen>
    with AutomaticKeepAliveClientMixin {
  bool isSchoolLevel = false;
  String? currentDeptCode;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserDeptAndFetch(); // 💡 Chỉ gọi hàm này, xóa cái context.read bị lỗi đi
  }

  // HÀM LẤY MÃ BỘ MÔN TỪ BỘ NHỚ
  Future<void> _loadUserDeptAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentDeptCode = prefs.getString('dept_code') ?? "";
    });

    if (currentDeptCode!.isNotEmpty) {
      if (!mounted) return;
      context.read<TbmCouncilBloc>().add(
        FetchTbmCouncilsEvent(
          isSchoolLevel: isSchoolLevel,
          deptCode: currentDeptCode!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 💡 Chờ lấy mã bộ môn xong mới hiện giao diện (để tránh lỗi currentDeptCode bị null)
    if (currentDeptCode == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "QUẢN LÝ HỘI ĐỒNG",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2962FF),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Thanh Tab Custom
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => isSchoolLevel = false);
                    context.read<TbmCouncilBloc>().add(
                      FetchTbmCouncilsEvent(
                        isSchoolLevel: false,
                        deptCode: currentDeptCode!, // 💡 Đã truyền deptCode
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: !isSchoolLevel
                          ? const Color(0xFFD6E4FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Cấp cơ sở",
                      style: TextStyle(
                        color: !isSchoolLevel
                            ? const Color(0xFF2962FF)
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() => isSchoolLevel = true);
                    context.read<TbmCouncilBloc>().add(
                      FetchTbmCouncilsEvent(
                        isSchoolLevel: true,
                        deptCode: currentDeptCode!, // 💡 Đã truyền deptCode
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSchoolLevel
                          ? const Color(0xFFD6E4FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Cấp trường",
                      style: TextStyle(
                        color: isSchoolLevel
                            ? const Color(0xFF2962FF)
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách hội đồng
          Expanded(
            child: BlocBuilder<TbmCouncilBloc, TbmCouncilState>(
              builder: (context, state) {
                if (state is TbmCouncilLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TbmCouncilError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is TbmCouncilLoaded) {
                  if (state.councils.isEmpty) {
                    return const Center(
                      child: Text(
                        "Hiện tại chưa có hội đồng nào",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TbmCouncilBloc>().add(
                        FetchTbmCouncilsEvent(
                          isSchoolLevel: isSchoolLevel,
                          deptCode: currentDeptCode!, // 💡 Đã truyền deptCode
                        ),
                      );
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: state.councils.length,
                      itemBuilder: (context, index) {
                        final council = state.councils[index];
                        return TbmCouncilCard(
                          councilName: council['council_name'] ?? 'N/A',
                          councilCode: council['council_code'] ?? 'N/A',
                          studentCount:
                              int.tryParse(
                                council['student_count'].toString(),
                              ) ??
                              0,
                          assignedCount:
                              int.tryParse(
                                council['assigned_count'].toString(),
                              ) ??
                              0,
                          quota: int.tryParse(council['quota'].toString()) ?? 0,
                          topicDirection:
                              council['topic_direction']?.toString() ??
                              'Chưa xác định',
                          isTimeValid: state.assignTimeStatus == 'OPEN',
                          onProposePressed: () async {
                            // 💡 Đã thêm chữ async vào đây
                            if (state.assignTimeStatus == 'LOCKED') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Chưa tới hạn phân công thành viên!",
                                  ),
                                ),
                              );
                              return;
                            } else if (state.assignTimeStatus == 'OVERDUE') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Đã quá hạn phân công thành viên!",
                                  ),
                                ),
                              );
                              return;
                            }

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => TbmCouncilDetailBloc(),
                                  child: TbmCouncilDetailScreen(
                                    councilId:
                                        int.tryParse(
                                          council['council_id'].toString(),
                                        ) ??
                                        0,
                                    councilCode:
                                        council['council_code'] ?? 'N/A',
                                    councilName:
                                        council['council_name'] ?? 'N/A',
                                    quota:
                                        int.tryParse(
                                          council['quota'].toString(),
                                        ) ??
                                        0,
                                  ),
                                ),
                              ),
                            );
                            if (context.mounted &&
                                currentDeptCode != null &&
                                currentDeptCode!.isNotEmpty) {
                              context.read<TbmCouncilBloc>().add(
                                FetchTbmCouncilsEvent(
                                  isSchoolLevel: isSchoolLevel,
                                  deptCode: currentDeptCode!,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

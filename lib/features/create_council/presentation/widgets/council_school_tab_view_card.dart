import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/constants/app_urls.dart';
import '../../../../core/untils/excel_helper.dart';
import '../bloc/council_bloc.dart';
import '../bloc/council_event.dart';
import '../bloc/council_state.dart';
import 'create_council_dialog_card.dart';
import 'council_card.dart';
import 'assign_department_dialog.dart';

class CouncilSchoolTabView extends StatefulWidget {
  const CouncilSchoolTabView({super.key});

  @override
  State<CouncilSchoolTabView> createState() => _CouncilSchoolTabViewState();
}

class _CouncilSchoolTabViewState extends State<CouncilSchoolTabView>
    with AutomaticKeepAliveClientMixin {
  String selectedFilter = 'Tất cả';

  final List<String> filterOptions = [
    'Tất cả',
    'Hội đồng thường',
    'Hội đồng tổng hợp',
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CouncilBloc>().add(
      FetchCouncilInfoEvent(isSchoolLevel: true, isRefresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      final state = context.read<CouncilBloc>().state;
      if (state is CouncilLoaded &&
          !state.hasReachedMax &&
          !state.isFetchingMore) {
        context.read<CouncilBloc>().add(
          FetchCouncilInfoEvent(isSchoolLevel: true),
        );
      }
    }
  }

  Future<void> _exportSchoolCouncil() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(
        Uri.parse(
          "${AppUrls.baseUrl}/api/council/export_admin_council_school.php",
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          bool success = await ExcelHelper.exportAdminSchoolCouncilExcel(
            fileName: "Tong_Hop_Hoi_Dong_Cap_Truong",
            students: data['students'],
            councils: data['councils'],
          );

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Lưu file Excel Cấp trường thành công!"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Lỗi khi ghi file!"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(
                "Cảnh báo",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(data['message']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Đóng"),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi kết nối máy chủ!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateDialog(BuildContext context, int totalSv) {
    final councilBloc = context.read<CouncilBloc>();
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: councilBloc,
        // 💡 Truyền cờ isSchoolLevel = true vào đây
        child: CreateCouncilDialog(totalStudents: totalSv, isSchoolLevel: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<CouncilBloc, CouncilState>(
      listener: (context, state) {
        if (state is CouncilActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CouncilError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is CouncilLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        int totalSv = 0;
        List<dynamic> councilList = [];
        String createTimeStatus = 'LOCKED';
        String assignTimeStatus = 'LOCKED';
        bool isFetchingMore = false;

        if (state is CouncilLoaded) {
          totalSv = state.totalStudents;
          councilList = state.councils;
          createTimeStatus = state.createTimeStatus;
          assignTimeStatus = state.assignTimeStatus;
          isFetchingMore = state.isFetchingMore;
        }

        List<dynamic> filteredCouncils = councilList.where((council) {
          if (selectedFilter == 'Tất cả') return true;
          String type = council['council_type']?.toString() ?? 'Thường';

          switch (selectedFilter) {
            case 'Hội đồng thường':
              return type == 'Thường';
            case 'Hội đồng tổng hợp':
              return type == 'Tổng hợp';
            default:
              return true;
          }
        }).toList();

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 💡 Validate theo mốc thời gian riêng của Cấp Trường
                        if (createTimeStatus == 'LOCKED') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Chưa qua hạn phân bộ môn Cơ sở, không thể tạo HĐ Cấp trường!",
                              ),
                            ),
                          );
                        } else if (createTimeStatus == 'OVERDUE') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đã quá hạn tạo HĐ Cấp trường!"),
                            ),
                          );
                        } else if (createTimeStatus == 'NO_BATCH') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Hiện tại chưa có đợt đồ án nào!"),
                            ),
                          );
                        } else {
                          _showCreateDialog(context, totalSv);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (createTimeStatus == 'OPEN')
                            ? const Color(0xFF2962FF)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Tạo hội đồng Cấp trường tự động",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: filterOptions.map((String value) {
                      final isSelected = selectedFilter == value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(value),
                          selected: isSelected,
                          showCheckmark: false,
                          onSelected: (bool selected) {
                            if (selected)
                              setState(() => selectedFilter = value);
                          },
                          selectedColor: const Color(
                            0xFF2962FF,
                          ).withOpacity(0.1),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF2962FF)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF2962FF)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Expanded(
                  child: filteredCouncils.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Chưa có Hội đồng Cấp trường nào",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 4,
                            bottom: 80,
                          ),
                          itemCount:
                              filteredCouncils.length +
                              (isFetchingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= filteredCouncils.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final council = filteredCouncils[index];
                            final memberCount =
                                int.tryParse(
                                  council['member_count'].toString(),
                                ) ??
                                0;
                            final bool isAlreadyAssigned =
                                council['department_code'] != null &&
                                council['department_code']
                                    .toString()
                                    .trim()
                                    .isNotEmpty;

                            return CouncilCard(
                              councilName: council['council_name'] ?? 'N/A',
                              councilCode: council['council_code'] ?? 'N/A',
                              studentCount:
                                  int.tryParse(
                                    council['student_count'].toString(),
                                  ) ??
                                  0,
                              memberCountText: memberCount == 0
                                  ? "Chưa có"
                                  : "$memberCount/5", // Giả sử HĐ Trường có 5 người
                              councilType: council['council_type'] ?? 'Thường',
                              topicDirection:
                                  council['topic_direction']?.toString() ??
                                  'Chưa phân loại',
                              showAssignButton:
                                  council['council_type'] == 'Tổng hợp',
                              isTimeValid: assignTimeStatus == 'OPEN',
                              isAssigned: isAlreadyAssigned,
                              onAssignPressed: () {
                                if (assignTimeStatus == 'LOCKED') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Chưa qua hạn nhập điểm, không thể phân bộ môn!",
                                      ),
                                    ),
                                  );
                                } else if (assignTimeStatus == 'OVERDUE') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Đã quá hạn phân bộ môn!"),
                                    ),
                                  );
                                } else if (assignTimeStatus == 'NO_BATCH') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Hiện tại chưa có đợt đồ án nào!",
                                      ),
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => BlocProvider.value(
                                      value: context.read<CouncilBloc>(),
                                      child: AssignDepartmentDialog(
                                        councilId:
                                            int.tryParse(
                                              council['council_id'].toString(),
                                            ) ??
                                            0,
                                        councilCode:
                                            council['council_code'] ?? 'N/A',
                                        isSchoolLevel: true,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),

            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: "export_school_btn",
                onPressed: _exportSchoolCouncil,
                backgroundColor: const Color(
                  0xFF2962FF,
                ), // Đổi màu xanh phân biệt Cấp Cơ Sở
                icon: const Icon(Icons.file_download, color: Colors.white),
                label: const Text(
                  "Xuất file",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

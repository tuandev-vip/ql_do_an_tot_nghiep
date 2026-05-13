import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http; // 💡 Import http
import 'dart:convert'; // 💡 Import json

import '../../../../core/constants/app_urls.dart';
// 💡 NHỚ SỬA ĐƯỜNG DẪN EXCEL HELPER NÀY CHO KHỚP VỚI MÁY ÔNG
import '../../../../core/untils/excel_helper.dart';

import '../bloc/council_bloc.dart';
import '../bloc/council_event.dart';
import '../bloc/council_state.dart';
import 'create_council_dialog_card.dart';
import 'council_card.dart';
import 'assign_department_dialog.dart';

class CouncilTabView extends StatefulWidget {
  final bool isSchoolLevel;

  const CouncilTabView({super.key, required this.isSchoolLevel});

  @override
  State<CouncilTabView> createState() => _CouncilTabViewState();
}

class _CouncilTabViewState extends State<CouncilTabView>
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
      FetchCouncilInfoEvent(
        isSchoolLevel: widget.isSchoolLevel,
        isRefresh: true,
      ),
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
          FetchCouncilInfoEvent(isSchoolLevel: widget.isSchoolLevel),
        );
      }
    }
  }

  // 💡 HÀM XUẤT FILE DÀNH RIÊNG CHO CẤP CƠ SỞ
  Future<void> _exportBaseCouncil() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(
        Uri.parse(
          "${AppUrls.baseUrl}/api/council/export_admin_council_base.php",
        ),
      );

      if (!mounted) return;
      Navigator.pop(context); // Tắt loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Gọi hàm xuất Excel
          bool success = await ExcelHelper.exportAdminBaseCouncilExcel(
            fileName: "Tong_Hop_Hoi_Dong_Co_So",
            students: data['students'],
            councils: data['councils'],
          );

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đã lưu file vào thư mục download!"),
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
          // Báo lỗi (VD: Hội đồng HĐCS01 thiếu người)
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
          int memberCount =
              int.tryParse(council['member_count']?.toString() ?? '0') ?? 0;

          switch (selectedFilter) {
            case 'Hội đồng thường':
              return type == 'Thường';
            case 'Hội đồng tổng hợp':
              return type == 'Tổng hợp';
            case 'HĐ thường (thiếu TV)':
              return type == 'Thường' && memberCount < 3;
            case 'HĐ tổng hợp (thiếu TV)':
              return type == 'Tổng hợp' && memberCount < 3;
            default:
              return true;
          }
        }).toList();

        // 💡 BỌC TẤT CẢ VÀO SCAFFOLD ĐỂ DÙNG NÚT NỔI
        return Scaffold(
          backgroundColor: Colors.transparent, // Không làm mất màu nền cũ
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (createTimeStatus == 'LOCKED') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Chưa qua hạn nhập điểm, không thể tạo hội đồng!",
                            ),
                          ),
                        );
                      } else if (createTimeStatus == 'OVERDUE') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đã quá hạn tạo hội đồng!"),
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
                      "Tạo hội đồng tự động",
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
                          if (selected) {
                            setState(() => selectedFilter = value);
                          }
                        },
                        selectedColor: const Color(0xFF2962FF).withOpacity(0.1),
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
                        child: Text(
                          "Không có hội đồng nào phù hợp",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 4,
                          bottom: 80, // Để chừa khoảng trống cho nút nổi
                        ),
                        itemCount:
                            filteredCouncils.length + (isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= filteredCouncils.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
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
                                : "$memberCount/3",
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
                                      isSchoolLevel: widget.isSchoolLevel,
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

          // 💡 ĐÂY LÀ NÚT XUẤT FILE NẰM TRONG TAB CƠ SỞ (Có HeroTag riêng)
          floatingActionButton: FloatingActionButton.extended(
            heroTag: "export_base_btn",
            onPressed: _exportBaseCouncil,
            backgroundColor: const Color(0xFFBDB76B),
            label: const Text(
              "Xuất file",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, int totalSv) {
    final councilBloc = context.read<CouncilBloc>();

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: councilBloc,
        child: CreateCouncilDialog(
          totalStudents: totalSv,
          isSchoolLevel: widget.isSchoolLevel,
        ),
      ),
    );
  }
}

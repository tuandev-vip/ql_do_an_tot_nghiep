import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/council_bloc.dart';
import '../bloc/council_event.dart';
import '../bloc/council_state.dart';
import 'create_council_dialog_card.dart';
import 'council_card.dart';

class CouncilTabView extends StatefulWidget {
  final bool isSchoolLevel;

  const CouncilTabView({super.key, required this.isSchoolLevel});

  @override
  State<CouncilTabView> createState() => _CouncilTabViewState();
}

// 💡 1. Thêm "with AutomaticKeepAliveClientMixin" vào đây
class _CouncilTabViewState extends State<CouncilTabView>
    with AutomaticKeepAliveClientMixin {
  String selectedFilter = 'Tất cả';

  final List<String> filterOptions = [
    'Tất cả',
    'Hội đồng thường',
    'Hội đồng tổng hợp',
  ];

  final ScrollController _scrollController = ScrollController();

  // 💡 2. Bật cờ KeepAlive để giữ trạng thái Tab không bị load lại
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // Lắng nghe ngón tay
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

  // 💡 Thuật toán kiểm tra chạm đáy
  void _onScroll() {
    // Nếu vuốt xuống cách đáy 50 pixel -> Bắn lệnh tải thêm
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

  @override
  Widget build(BuildContext context) {
    // 💡 3. BẮT BUỘC phải có dòng này ở đầu hàm build để kích hoạt bùa KeepAlive
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
        String timeStatus = 'LOCKED';
        bool isFetchingMore = false;

        if (state is CouncilLoaded) {
          totalSv = state.totalStudents;
          councilList = state.councils;
          timeStatus = state.timeStatus;
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💡 NÚT TẠO HỘI ĐỒNG
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (timeStatus == 'LOCKED') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Chưa qua hạn nhập điểm, không thể tạo hội đồng!",
                          ),
                        ),
                      );
                    } else if (timeStatus == 'OVERDUE') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã quá hạn tạo hội đồng!"),
                        ),
                      );
                    } else if (timeStatus == 'NO_BATCH') {
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
                    backgroundColor: (timeStatus == 'OPEN')
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

            // 💡 THANH LỌC DẠNG THẺ VUỐT NGANG
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: filterOptions.map((String value) {
                  final isSelected = selectedFilter == value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(value),
                      selected: isSelected,
                      showCheckmark: false, // Tắt dấu tick cho hiện đại
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

            // 💡 DANH SÁCH
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
                        bottom: 80,
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
                            int.tryParse(council['member_count'].toString()) ??
                            0;

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
                        );
                      },
                    ),
            ),
          ],
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
        child: CreateCouncilDialog(totalStudents: totalSv),
      ),
    );
  }
}

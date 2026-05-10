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

class _CouncilTabViewState extends State<CouncilTabView> {
  String selectedFilter = 'Tất cả';

  final List<String> filterOptions = [
    'Tất cả',
    'Hội đồng thường',
    'Hội đồng tổng hợp',
    'HĐ thường (thiếu TV)',
    'HĐ tổng hợp (thiếu TV)',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CouncilBloc>().add(FetchCouncilInfoEvent());
  }

  @override
  Widget build(BuildContext context) {
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

        if (state is CouncilLoaded) {
          totalSv = state.totalStudents;
          councilList = state.councils;
          timeStatus = state.timeStatus;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedFilter,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (String? newValue) {
                            setState(() => selectedFilter = newValue!);
                          },
                          items: filterOptions.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Tạo hội đồng",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: councilList.isEmpty
                  ? const Center(
                      child: Text(
                        "Chưa có hội đồng nào được tạo",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: councilList.length,
                      itemBuilder: (context, index) {
                        final council = councilList[index];
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
        // 💡 2. Dùng BlocProvider.value để "tuồn" cái Bloc đó vào trong Popup
        value: councilBloc,
        child: CreateCouncilDialog(totalStudents: totalSv),
      ),
    );
  }
}

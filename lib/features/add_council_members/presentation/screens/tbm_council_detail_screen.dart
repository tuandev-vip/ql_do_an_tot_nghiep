import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/add_council_members/presentation/widgets/tbm_lecturer_picker_sheet_card.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 Import SharedPreferences

import '../bloc/tbm_council_detail_bloc.dart';
import '../bloc/tbm_council_detail_event.dart';
import '../bloc/tbm_council_detail_state.dart';
import '../widgets/tbm_student_card.dart';

// 💡 Import 2 file mới của Bottom Sheet chọn Giảng Viên
import '../bloc/tbm_lecturer_picker_bloc.dart';

class TbmCouncilDetailScreen extends StatefulWidget {
  final int councilId;
  final String councilName;
  final String councilCode;
  final int quota;

  const TbmCouncilDetailScreen({
    super.key,
    required this.councilId,
    required this.councilName,
    required this.councilCode,
    required this.quota,
  });

  @override
  State<TbmCouncilDetailScreen> createState() => _TbmCouncilDetailScreenState();
}

class _TbmCouncilDetailScreenState extends State<TbmCouncilDetailScreen> {
  late List<String?> assignedLecturers;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    assignedLecturers = List.filled(widget.quota, null);

    // Gọi API lấy danh sách SV lần đầu
    context.read<TbmCouncilDetailBloc>().add(
      FetchStudentsEvent(widget.councilId, isRefresh: true),
    );

    // Lắng nghe sự kiện chạm đáy
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        final state = context.read<TbmCouncilDetailBloc>().state;
        if (state is DetailLoaded &&
            !state.hasReachedMax &&
            !state.isFetchingMore) {
          context.read<TbmCouncilDetailBloc>().add(
            FetchStudentsEvent(widget.councilId),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 💡 HÀM MỚI: MỞ POPUP CHỌN GIẢNG VIÊN (SỬ DỤNG BLOC)
  Future<void> _showLecturerPicker(int slotIndex) async {
    // 1. Lấy mã bộ môn của TBM đang đăng nhập từ thiết bị
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String myDeptCode = prefs.getString('dept_code') ?? "";

    if (myDeptCode.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: Không tìm thấy mã bộ môn!")),
      );
      return;
    }

    if (!mounted) return;

    // 2. Mở Bottom Sheet và chờ kết quả người dùng chọn
    final selectedLecturer = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocProvider(
          create: (context) => TbmLecturerPickerBloc(),
          child: TbmLecturerPickerSheet(deptCode: myDeptCode),
        );
      },
    );

    // 3. Nếu người dùng có chọn GV và bấm Lưu
    if (selectedLecturer != null) {
      setState(() {
        // Cập nhật tên GV vào ô (Sau này làm tính năng API Lưu HĐ thì nhớ lấy selectedLecturer['user_id'] nữa nhé)
        assignedLecturers[slotIndex] = selectedLecturer['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💡 THẺ PHÂN THÀNH VIÊN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2962FF),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      widget.councilName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thành viên",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(widget.quota, (index) {
                          bool isAssigned = assignedLecturers[index] != null;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAssigned
                                      ? assignedLecturers[index]!
                                      : "Chưa có",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: isAssigned
                                        ? FontStyle.normal
                                        : FontStyle.italic,
                                    color: Colors.black87,
                                    fontWeight: isAssigned
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                SizedBox(
                                  height: 32,
                                  child: OutlinedButton(
                                    onPressed: () => _showLecturerPicker(
                                      index,
                                    ), // 💡 Gọi hàm mở popup mới
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                    ),
                                    child: Text(
                                      isAssigned ? "Sửa" : "Thêm",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "Danh sách sinh viên:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2962FF),
              ),
            ),
            const SizedBox(height: 8),

            // 💡 DANH SÁCH SINH VIÊN (Dùng BLoC và Thẻ TbmStudentCard)
            BlocBuilder<TbmCouncilDetailBloc, TbmCouncilDetailState>(
              builder: (context, state) {
                if (state is DetailLoading) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is DetailError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is DetailLoaded) {
                  if (state.students.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Hội đồng này chưa có sinh viên nào",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.students.length,
                        itemBuilder: (context, index) {
                          final sv = state.students[index];

                          // 💡 GỌI THẺ SINH VIÊN RA ĐÂY
                          return TbmStudentCard(
                            name: sv['name'] ?? 'Chưa cập nhật',
                            studentCode: sv['student_code'] ?? 'N/A',
                            phone: sv['phone'] ?? 'N/A',
                            className: sv['class_name'] ?? 'N/A',
                            email: sv['email'] ?? 'N/A',
                            projectName:
                                sv['project_name'] ?? 'Đang cập nhật...',
                          );
                        },
                      ),
                      if (state.isFetchingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}

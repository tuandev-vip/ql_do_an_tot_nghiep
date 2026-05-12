import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/add_council_members/presentation/widgets/tbm_lecturer_picker_sheet_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // 💡 Gọi API trực tiếp
import 'dart:convert'; // 💡 Xử lý JSON

import '../../../../core/constants/app_urls.dart'; // 💡 Nhớ import AppUrls
import '../bloc/tbm_council_detail_bloc.dart';
import '../bloc/tbm_council_detail_event.dart';
import '../bloc/tbm_council_detail_state.dart';
import '../widgets/tbm_student_card.dart';
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
  // 💡 NÂNG CẤP: Lưu cả Object (Tên + ID) thay vì chỉ lưu Tên
  late List<Map<String, dynamic>?> assignedLecturers;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMembers = true; // 💡 Hiệu ứng loading lúc nạp GV

  @override
  void initState() {
    super.initState();
    assignedLecturers = List.filled(widget.quota, null);

    // 1. Tải danh sách Sinh viên
    context.read<TbmCouncilDetailBloc>().add(
      FetchStudentsEvent(widget.councilId, isRefresh: true),
    );

    // 2. 💡 Tải các Giảng viên ĐÃ ĐƯỢC PHÂN CÔNG từ trước
    _loadExistingMembers();

    // 3. Cuộn đáy load SV
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

  // 💡 HÀM: TẢI DANH SÁCH GV TỪ DATABASE LÊN UI
  Future<void> _loadExistingMembers() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${AppUrls.baseUrl}/api/council/get_tbm_council_members.php?council_id=${widget.councilId}",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> members = data['members'];
          setState(() {
            for (int i = 0; i < members.length; i++) {
              if (i < widget.quota) {
                // Nhét từng GV cũ vào đúng slot
                assignedLecturers[i] = {
                  'user_id': members[i]['user_id'],
                  'name': members[i]['name'],
                };
              }
            }
            _isLoadingMembers = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoadingMembers = false);
    }
  }

  // 💡 HÀM: LƯU GV VÀO DATABASE KHI CHỌN TỪ BOTTOM SHEET
  // 💡 HÀM: LƯU GV VÀO DATABASE KHI CHỌN TỪ BOTTOM SHEET
  // 💡 HÀM: LƯU GV VÀO DATABASE KHI CHỌN TỪ BOTTOM SHEET
  Future<void> _saveMemberToDb(
    int slotIndex,
    Map<String, dynamic> newLecturer,
  ) async {
    // 💡 ÉP KIỂU SIÊU AN TOÀN: Dù PHP trả về String hay Int đều parse được hết, tránh Crash ngầm
    int oldUserId =
        int.tryParse(
          assignedLecturers[slotIndex]?['user_id']?.toString() ?? '0',
        ) ??
        0;
    int newUserId =
        int.tryParse(newLecturer['user_id']?.toString() ?? '0') ?? 0;

    // 💡 FIX LỖI ĐƠ: Nếu Sửa mà chọn lại ĐÚNG ông cũ -> Báo vàng và Dừng luôn
    if (oldUserId != 0 && oldUserId == newUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giảng viên này đang đảm nhiệm vị trí này rồi!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Bật vòng xoay Loading khóa màn hình
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Đóng gói data gửi lên API
      Map<String, String> bodyData = {
        'council_id': widget.councilId.toString(),
        'new_user_id': newUserId.toString(),
      };
      if (oldUserId != 0) {
        bodyData['old_user_id'] = oldUserId.toString();
      }

      final response = await http.post(
        Uri.parse(
          "${AppUrls.baseUrl}/api/council/assign_tbm_council_member.php",
        ),
        body: bodyData,
      );

      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // Tắt vòng xoay Loading an toàn

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.green,
            ),
          );
          // Cập nhật lại UI
          setState(() {
            assignedLecturers[slotIndex] = newLecturer;
          });
        } else {
          // Báo lỗi (VD: Bị trùng GV ở Slot khác)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Tắt Loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi kết nối máy chủ"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // MỞ POPUP CHỌN GIẢNG VIÊN
  Future<void> _showLecturerPicker(int slotIndex) async {
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

    // 💡 GỌI HÀM LƯU VÀO DATABASE KHI CHỌN XONG
    if (selectedLecturer != null) {
      await _saveMemberToDb(slotIndex, selectedLecturer);
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
            // THẺ PHÂN THÀNH VIÊN
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
                    child: _isLoadingMembers
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          ) // Hiển thị loading nếu đang tải dữ liệu cũ
                        : Column(
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
                                bool isAssigned =
                                    assignedLecturers[index] != null;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        // 💡 Lấy giá trị 'name' từ Object
                                        isAssigned
                                            ? assignedLecturers[index]!['name']
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
                                          onPressed: () =>
                                              _showLecturerPicker(index),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
              "Danh sách sinh viên :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // DANH SÁCH SINH VIÊN BẢO VỆ
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

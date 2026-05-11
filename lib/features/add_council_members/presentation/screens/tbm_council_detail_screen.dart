import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tbm_council_detail_bloc.dart';
import '../bloc/tbm_council_detail_event.dart';
import '../bloc/tbm_council_detail_state.dart';
import '../widgets/tbm_student_card.dart'; // 💡 Đã import Thẻ Sinh Viên

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

  // Mock data giảng viên
  final List<Map<String, String>> mockLecturers = [
    {
      "name": "Nguyễn Văn A",
      "email": "DTC25250225@ictu.edu.vn",
      "id": "GV01",
      "dept": "Mạng máy tính",
      "count": "2",
    },
    {
      "name": "Trần Thị B",
      "email": "DTC25250226@ictu.edu.vn",
      "id": "GV02",
      "dept": "Mạng máy tính",
      "count": "1",
    },
  ];

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

  // 💡 HÀM MỞ POPUP CHỌN GIẢNG VIÊN
  void _showLecturerPicker(int slotIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm GVHD",
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: mockLecturers.length,
                  itemBuilder: (context, index) {
                    final gv = mockLecturers[index];
                    return GestureDetector(
                      onTap: () {
                        setState(
                          () => assignedLecturers[slotIndex] = gv["name"],
                        );
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gv["name"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow("Email", gv["email"]!),
                            const SizedBox(height: 4),
                            _buildInfoRow("Mã giảng viên", gv["id"]!),
                            const SizedBox(height: 4),
                            _buildInfoRow("Bộ môn", gv["dept"]!),
                            const SizedBox(height: 4),
                            _buildInfoRow(
                              "Số lượng hội đồng tham gia",
                              gv["count"]!,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
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
                                    onPressed: () => _showLecturerPicker(index),
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

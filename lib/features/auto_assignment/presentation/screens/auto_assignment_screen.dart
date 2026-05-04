import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/excel_helper.dart';
import '../bloc/auto_assignment_bloc.dart';
import '../bloc/auto_assignment_event.dart';
import '../bloc/auto_assignment_state.dart';
import '../widgets/auto_assignment_card.dart';
import 'package:excel/excel.dart' hide Border;

class AutoAssignmentScreen extends StatefulWidget {
  final String deptId;
  const AutoAssignmentScreen({super.key, required this.deptId});

  @override
  State<AutoAssignmentScreen> createState() => _AutoAssignmentScreenState();
}

class _AutoAssignmentScreenState extends State<AutoAssignmentScreen> {
  String _selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    // Load dữ liệu ban đầu
    context.read<AutoAssignmentBloc>().add(
      FetchAutoAssignmentStudents("all", widget.deptId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "PHÂN CÔNG GIẢNG VIÊN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: BlocListener<AutoAssignmentBloc, AutoAssignmentState>(
        listener: (context, state) {
          if (state is AutoAssignmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Thanh công cụ: Chọn bộ lọc và Nút phân công
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: "all",
                              child: Text("Tất cả sinh viên"),
                            ),
                            DropdownMenuItem(
                              value: "not_assigned",
                              child: Text("Chưa có GVHD"),
                            ),
                            DropdownMenuItem(
                              value: "assigned",
                              child: Text("Đã có GVHD"),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedFilter = val!);
                            context.read<AutoAssignmentBloc>().add(
                              FetchAutoAssignmentStudents(val!, widget.deptId),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => context.read<AutoAssignmentBloc>().add(
                      TriggerAutoAssign(widget.deptId),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Phân tự động",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách hiển thị
            Expanded(
              child: BlocBuilder<AutoAssignmentBloc, AutoAssignmentState>(
                builder: (context, state) {
                  if (state is AutoAssignmentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AutoAssignmentLoaded) {
                    if (state.students.isEmpty) {
                      return const Center(
                        child: Text("Không có dữ liệu phù hợp"),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.students.length,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemBuilder: (context, index) =>
                          AutoAssignmentCard(student: state.students[index]),
                    );
                  }
                  return const Center(child: Text("Vui lòng chọn bộ lọc"));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<AutoAssignmentBloc, AutoAssignmentState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: () async {
              if (state is AutoAssignmentLoaded) {
                // 1. Kiểm tra phải đang ở Tab "Tất cả" mới cho xuất
                if (_selectedFilter != 'all') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Vui lòng chọn bộ lọc 'Tất cả sinh viên' để xuất file.",
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // 2. Kiểm tra xem còn SV nào bơ vơ không
                bool hasUnassigned = state.students.any(
                  (s) => s.status != 'APPROVED',
                );
                if (hasUnassigned) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lỗi: Vẫn còn sinh viên chưa có GVHD!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // 3. Chuẩn bị dữ liệu (Headers)
                List<String> headers = [
                  'STT',
                  'Mã sinh viên',
                  'Tên sinh viên',
                  'Lớp',
                  'Tên giảng viên hướng dẫn',
                ];

                // 4. Chuẩn bị dữ liệu (Rows)
                List<List<CellValue>> rows = [];
                for (int i = 0; i < state.students.length; i++) {
                  var s = state.students[i];
                  rows.add([
                    IntCellValue(i + 1),
                    TextCellValue(s.studentCode),
                    TextCellValue(s.studentName),
                    TextCellValue(s.className ?? ''),
                    TextCellValue(s.teacherName ?? ''),
                  ]);
                }

                // 5. Gọi hàm từ file dùng chung
                bool success = await ExcelHelper.exportToExcel(
                  fileName: 'Phan_Cong_GVHD_Bo_Mon_${widget.deptId}',
                  deptId: widget
                      .deptId, // Truyền deptId xuống đây để nhét vào dòng A1
                  headers: headers,
                  dataRows: rows,
                );

                // 6. Thông báo kết quả
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Xuất file Excel thành công!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Có lỗi xảy ra khi lưu file!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            label: const Text(
              "Xuất file",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(Icons.file_download, color: Colors.white),
            backgroundColor: Colors.green.shade600,
          );
        },
      ),
    );
  }
}

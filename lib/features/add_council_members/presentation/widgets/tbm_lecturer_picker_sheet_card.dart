import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tbm_lecturer_picker_bloc.dart';
import '../bloc/tbm_lecturer_picker_event.dart';
import '../bloc/tbm_lecturer_picker_state.dart';

class TbmLecturerPickerSheet extends StatefulWidget {
  final String deptCode;

  const TbmLecturerPickerSheet({super.key, required this.deptCode});

  @override
  State<TbmLecturerPickerSheet> createState() => _TbmLecturerPickerSheetState();
}

class _TbmLecturerPickerSheetState extends State<TbmLecturerPickerSheet> {
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _selectedLecturer;

  // 💡 1. THÊM BIẾN LƯU TỪ KHÓA TÌM KIẾM
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TbmLecturerPickerBloc>().add(
      FetchLecturersEvent(widget.deptCode, isRefresh: true),
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        final state = context.read<TbmLecturerPickerBloc>().state;
        // 💡 Chỉ load thêm khi KHÔNG GÕ TÌM KIẾM (để tránh lỗi danh sách khi đang lọc)
        if (state is PickerLoaded &&
            !state.hasReachedMax &&
            !state.isFetchingMore &&
            _searchQuery.isEmpty) {
          context.read<TbmLecturerPickerBloc>().add(
            FetchLecturersEvent(widget.deptCode),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // 💡 Nhớ dọn dẹp bộ nhớ
    super.dispose();
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color color = Colors.black,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
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
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  // 💡 2. CẬP NHẬT THANH TÌM KIẾM
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value; // Cập nhật từ khóa mỗi khi gõ
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm tên GVHD...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      // Nút X để xóa nhanh từ khóa
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = "");
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách Giảng viên
          Expanded(
            child: BlocBuilder<TbmLecturerPickerBloc, TbmLecturerPickerState>(
              builder: (context, state) {
                if (state is PickerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PickerError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is PickerLoaded) {
                  // 💡 3. LOGIC LỌC DANH SÁCH THEO TÊN
                  final filteredLecturers = state.lecturers.where((gv) {
                    final name = gv['name']?.toString().toLowerCase() ?? "";
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();

                  // Nếu gõ tìm mà không ra ai
                  if (filteredLecturers.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? "Không có giảng viên nào"
                            : "Không tìm thấy giảng viên '$_searchQuery'",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // 💡 Dùng danh sách đã lọc (filteredLecturers) thay vì danh sách gốc
                    itemCount:
                        filteredLecturers.length +
                        (state.isFetchingMore && _searchQuery.isEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredLecturers.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final gv = filteredLecturers[index];
                      bool isSelected =
                          _selectedLecturer != null &&
                          _selectedLecturer!['user_id'] == gv['user_id'];

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedLecturer = gv);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE3F2FD)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2962FF)
                                  : Colors.grey.shade400,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gv["name"] ?? "N/A",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow("Email", gv["email"] ?? "N/A"),
                              const SizedBox(height: 4),
                              _buildInfoRow("Mã giảng viên", gv["id"] ?? "N/A"),
                              const SizedBox(height: 4),
                              _buildInfoRow("Bộ môn", gv["dept"] ?? "N/A"),
                              const SizedBox(height: 4),
                              _buildInfoRow(
                                "Hội đồng tham gia",
                                gv["count"].toString(),
                                color: int.parse(gv["count"].toString()) >= 3
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // Nút Lưu
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedLecturer == null
                  ? null
                  : () => Navigator.pop(context, _selectedLecturer),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                disabledBackgroundColor: Colors.grey,
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
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_grade_bloc.dart';
import '../bloc/teacher_grade_event.dart';
import '../bloc/teacher_grade_state.dart';

class TeacherGradeTab extends StatefulWidget {
  final String studentId;
  const TeacherGradeTab({super.key, required this.studentId});

  @override
  State<TeacherGradeTab> createState() => _TeacherGradeTabState();
}

class _TeacherGradeTabState extends State<TeacherGradeTab> {
  final TextEditingController _scoreController = TextEditingController();

  // 💡 FLAG QUAN TRỌNG: Dùng để chuyển đổi qua lại giữa chế độ Xem và Sửa
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<TeacherGradeBloc>().add(FetchGradeInfo(widget.studentId));
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  void _submitGrade() {
    if (_scoreController.text.isEmpty) return;
    double? score = double.tryParse(_scoreController.text);
    if (score == null || score < 0 || score > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Điểm phải là số từ 0 đến 10!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    context.read<TeacherGradeBloc>().add(
      SubmitTeacherGrade(widget.studentId, score),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherGradeBloc, TeacherGradeState>(
      listener: (context, state) {
        if (state is TeacherGradeUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          FocusScope.of(context).unfocus(); // Thu bàn phím
          setState(() {
            _isEditing =
                false; // 💡 ĐIỂM NHẤN: Lưu thành công thì tự động gập Form lại, chuyển sang chế độ Xem
          });
        } else if (state is TeacherGradeLoaded && state.score != null) {
          // Lấy điểm cũ gán vào ô text nếu muốn sửa
          _scoreController.text = state.score.toString();
        }
      },
      builder: (context, state) {
        if (state is TeacherGradeLoading || state is TeacherGradeInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TeacherGradeError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        if (state is TeacherGradeLoaded) {
          return _buildForm(state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildForm(TeacherGradeLoaded state) {
    // 💡 LOGIC HIỂN THỊ FORM: Chỉ hiện khi chưa có điểm nào (lần đầu) HOẶC khi GV bấm nút "Sửa"
    bool showForm = state.score == null || _isEditing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TRẠNG THÁI 1: CHƯA MỞ ---
          if (state.timeStatus == "LOCKED") ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Hệ thống chấm điểm sẽ được mở từ\n${state.openTime} đến ${state.closeTime}",
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ]
          // --- TRẠNG THÁI 2: ĐÃ QUÁ HẠN ---
          else if (state.timeStatus == "OVERDUE") ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Đã khóa sổ nhập điểm vào lúc:\n${state.closeTime}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state.score != null)
              _buildScoreDisplay(state.score!) // Hiện ô điểm để xem, cấm sửa
            else
              const Text(
                "Giảng viên đã bỏ lỡ thời gian nhập điểm cho sinh viên này.",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
          ]
          // --- TRẠNG THÁI 3: ĐANG MỞ ---
          else if (state.timeStatus == "OPEN") ...[
            Text(
              "Hạn chót nhập điểm: ${state.closeTime}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            if (showForm) ...[
              // 👉 CHẾ ĐỘ NHẬP / SỬA ĐIỂM
              TextField(
                controller: _scoreController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Điểm hướng dẫn (Hệ 10)",
                  border: OutlineInputBorder(),
                  hintText: "Ví dụ: 8.5",
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (state.score != null) ...[
                    // Nút Hủy (Chỉ hiện khi đang sửa điểm đã có)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false; // Gập form lại
                            _scoreController.text = state.score
                                .toString(); // Trả lại text về điểm cũ
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Nút Lưu
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitGrade,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        state.score == null ? "Lưu Điểm" : "Cập nhật",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // 👉 CHẾ ĐỘ XEM ĐIỂM XỊN XÒ
              _buildScoreDisplay(state.score!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing =
                          true; // Bật cờ thành True để bung Form nhập ra
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Sửa Điểm",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // 💡 GIAO DIỆN HIỂN THỊ ĐIỂM RIÊNG BIỆT SAU KHI LƯU
  Widget _buildScoreDisplay(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Điểm hướng dẫn: ",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            "$score",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

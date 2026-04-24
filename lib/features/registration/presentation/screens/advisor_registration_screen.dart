import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../widgets/teacher_card.dart';
import '../../../user/data/models/teacher_model.dart';

class AdvisorRegistrationScreen extends StatefulWidget {
  final String studentId;
  const AdvisorRegistrationScreen({super.key, required this.studentId});

  @override
  State<AdvisorRegistrationScreen> createState() =>
      _AdvisorRegistrationScreenState();
}

class _AdvisorRegistrationScreenState extends State<AdvisorRegistrationScreen> {
  // Biến dùng để khóa giao diện (xám nút) khi sinh viên đã gửi yêu cầu thành công
  String? registeredTeacherId;

  @override
  void initState() {
    super.initState();
    // Vừa vào màn hình là gọi lấy danh sách giảng viên ngay
    context.read<RegistrationBloc>().add(FetchTeachersEvent(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "ĐĂNG KÝ GIẢNG VIÊN & ĐỀ TÀI",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            // 1. Hiện SnackBar xanh báo thành công
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // 2. Cập nhật biến trạng thái để UI xám nút ngay lập tức
            setState(() {
              registeredTeacherId = state.teacherId;
            });

            // 3. Tải lại danh sách để cập nhật số lượng sinh viên (ví dụ 0/8 lên 1/8)
            context.read<RegistrationBloc>().add(
              FetchTeachersEvent(widget.studentId),
            );
          } else if (state is RegistrationError) {
            // Hiện SnackBar đỏ báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Column(
          children: [
            // 1. THANH TÌM KIẾM
            _buildSearchField(context),

            // 2. DANH SÁCH GIẢNG VIÊN
            Expanded(
              child: BlocBuilder<RegistrationBloc, RegistrationState>(
                builder: (context, state) {
                  if (state is RegistrationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Hứng dữ liệu từ tất cả các trạng thái có chứa list giảng viên
                  if (state is TeachersLoaded) {
                    return _buildTeacherList(state.teachers);
                  }
                  if (state is RegistrationSuccess) {
                    return _buildTeacherList(state.teachers);
                  }
                  if (state is RegistrationError) {
                    return _buildTeacherList(state.teachers);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherList(List<TeacherModel> teachers) {
    // 1. Kiểm tra an toàn: Có thầy nào đã duyệt (APPROVED) cho mình chưa?
    // Dùng trim() và toUpperCase() để tránh lỗi dữ liệu
    final approvedTeacher = teachers.cast<TeacherModel?>().firstWhere(
      (t) => t?.myRegistrationStatus?.trim().toUpperCase() == 'APPROVED',
      orElse: () => null,
    );

    // 2. NẾU ĐÃ ĐƯỢC DUYỆT: Hiện màn hình chúc mừng, ẩn danh sách
    if (approvedTeacher != null) {
      return _buildAlreadyHasAdvisorView(approvedTeacher);
    }

    // 3. NẾU CHƯA ĐƯỢC DUYỆT: Kiểm tra xem có yêu cầu nào đang chờ (PENDING) không
    bool hasAnyRequest =
        registeredTeacherId != null ||
        teachers.any(
          (t) => t.myRegistrationStatus?.trim().toUpperCase() == 'PENDING',
        );

    return ListView.builder(
      itemCount: teachers.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        String status =
            teacher.myRegistrationStatus?.trim().toUpperCase() ?? "";

        // Xám nút nếu là GV đã đăng ký (PENDING) hoặc đúng ID vừa nhấn
        bool isThisTeacher =
            (teacher.id == registeredTeacherId) || (status == 'PENDING');

        return TeacherCard(
          teacher: teacher,
          studentId: widget.studentId,
          isThisTeacher: isThisTeacher,
          hasAnyRequest: hasAnyRequest,
        );
      },
    );
  }

  Widget _buildAlreadyHasAdvisorView(TeacherModel teacher) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              "BẠN ĐÃ CÓ GIẢNG VIÊN HƯỚNG DẪN",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "GV: ${teacher.fullName}",
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            const Text(
              "Vui lòng chuyển sang Tab 'Báo cáo' để bắt đầu làm việc.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Widget thanh tìm kiếm
  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) =>
            context.read<RegistrationBloc>().add(SearchTeacherEvent(value)),
        decoration: InputDecoration(
          hintText: "Nhập tên giảng viên...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

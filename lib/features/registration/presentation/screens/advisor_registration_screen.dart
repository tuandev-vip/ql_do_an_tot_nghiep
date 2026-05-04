import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../widgets/teacher_card.dart';
import '../../../user/data/models/teacher_model.dart';
// ĐỪNG QUÊN IMPORT MÀN HÌNH NÀY NẾU NÓ BÁO ĐỎ NHÉ
import '../widgets/registration_expired_view.dart';

class AdvisorRegistrationScreen extends StatefulWidget {
  final String studentId;
  const AdvisorRegistrationScreen({super.key, required this.studentId});

  @override
  State<AdvisorRegistrationScreen> createState() =>
      _AdvisorRegistrationScreenState();
}

class _AdvisorRegistrationScreenState extends State<AdvisorRegistrationScreen> {
  String? registeredTeacherId;

  @override
  void initState() {
    super.initState();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() {
              registeredTeacherId = state.teacherId;
            });
            context.read<RegistrationBloc>().add(
              FetchTeachersEvent(widget.studentId),
            );
          } else if (state is RegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, state) {
            if (state is RegistrationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 1. HỨNG DỮ LIỆU TỪ TẤT CẢ CÁC TRẠNG THÁI (KỂ CẢ EXPIRED)
            List<TeacherModel> teachers = [];
            if (state is TeachersLoaded) {
              teachers = state.teachers;
            } else if (state is RegistrationSuccess) {
              teachers = state.teachers;
            } else if (state is RegistrationError) {
              teachers = state.teachers;
            } else if (state is RegistrationExpired) {
              teachers = state
                  .teachers; // <--- ĐÂY LÀ DÒNG QUAN TRỌNG NHẤT ÔNG BỊ THIẾU NÈ!
            }

            // 2. KIỂM TRA ƯU TIÊN TUYỆT ĐỐI: Có thầy nào đã duyệt (APPROVED) chưa?
            final approvedTeacher = teachers.cast<TeacherModel?>().firstWhere(
              (t) =>
                  t?.myRegistrationStatus?.trim().toUpperCase() == 'APPROVED',
              orElse: () => null,
            );

            // 3. NẾU ĐÃ ĐƯỢC DUYỆT: Kệ quá hạn hay không, cứ trùm full màn hình tick xanh!
            if (approvedTeacher != null) {
              return _buildAlreadyHasAdvisorView(approvedTeacher);
            }

            // 4. NẾU CHƯA CÓ GVHD MÀ LẠI BỊ QUÁ HẠN: Hiện cái đồng hồ đỏ
            if (state is RegistrationExpired) {
              return RegistrationExpiredView(
                batchName: state.batchName,
                deadline: state.deadline,
              );
            }

            // 5. NẾU VẪN CÒN HẠN VÀ CHƯA CÓ GVHD: Hiện thanh tìm kiếm bình thường
            return Column(
              children: [
                _buildSearchField(context),
                Expanded(child: _buildTeacherList(teachers)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeacherList(List<TeacherModel> teachers) {
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

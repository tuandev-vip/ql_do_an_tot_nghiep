import 'package:flutter/material.dart';
import 'package:ql_do_an_tot_nghiep/features/registration/presentation/bloc/registration_bloc.dart';
import '../../../user/data/models/teacher_model.dart';
import 'registration_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  final String studentId;
  final bool isThisTeacher; // Trạng thái: Đây có phải GV mà SV đã đăng ký?
  final bool hasAnyRequest; // Trạng thái: SV đã đăng ký bất kỳ GV nào chưa?

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.studentId,
    this.isThisTeacher = false,
    this.hasAnyRequest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildInfoRow("Email", teacher.email),
          _buildInfoRow("Bộ môn", teacher.departmentName),
          _buildInfoRow("Số điện thoại", teacher.phone),
          const SizedBox(height: 16),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          teacher.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "${teacher.currentStudents}/${teacher.maxStudents}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Vô hiệu hóa nút nếu đã có bất kỳ yêu cầu nào
        onPressed: hasAnyRequest ? null : () => _showRegDialog(context),
        style: ElevatedButton.styleFrom(
          // Màu sắc thay đổi theo trạng thái
          backgroundColor: isThisTeacher
              ? Colors.orangeAccent
              : (hasAnyRequest ? Colors.grey[400] : Colors.blueAccent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          isThisTeacher
              ? "Đã gửi yêu cầu"
              : (hasAnyRequest ? "Khóa đăng ký" : "Đăng ký giảng viên"),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showRegDialog(BuildContext context) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        // 2. "Bắn" cái Bloc này vào trong Dialog
        value: registrationBloc,
        child: RegistrationDialog(teacher: teacher, studentId: studentId),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../../../user/data/models/teacher_model.dart';

class AdvisorRegistrationScreen extends StatefulWidget {
  const AdvisorRegistrationScreen({super.key});

  @override
  State<AdvisorRegistrationScreen> createState() =>
      _AdvisorRegistrationScreenState();
}

class _AdvisorRegistrationScreenState extends State<AdvisorRegistrationScreen> {
  @override
  void initState() {
    super.initState();
    // Vừa vào màn hình là gọi lấy danh sách giảng viên ngay
    context.read<RegistrationBloc>().add(FetchTeachersEvent());
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
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                // Gửi từ khóa vào Bloc để lọc
                context.read<RegistrationBloc>().add(SearchTeacherEvent(value));
              },
              decoration: InputDecoration(
                hintText: "Nhập tên giảng viên...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. DANH SÁCH GIẢNG VIÊN
          Expanded(
            child: BlocBuilder<RegistrationBloc, RegistrationState>(
              builder: (context, state) {
                if (state is RegistrationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TeachersLoaded) {
                  return ListView.builder(
                    itemCount: state.teachers.length,
                    itemBuilder: (context, index) =>
                        _buildTeacherCard(context, state.teachers[index]),
                  );
                } else if (state is RegistrationError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Card Giảng viên
  Widget _buildTeacherCard(BuildContext context, TeacherModel teacher) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                teacher.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "Số lượng: ${teacher.currentStudents}/${teacher.maxStudents}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Email", teacher.email),
          _buildInfoRow("Bộ môn", teacher.departmentName),
          _buildInfoRow("Số điện thoại", teacher.phone),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  _showRegDialog(context, teacher), // Bước tiếp theo làm Dialog
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Đăng ký giảng viên",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  void _showRegDialog(BuildContext context, TeacherModel teacher) {
    // Tạm thời để đây, lát mình sẽ làm cái Dialog nhập hướng đề tài
  }
}

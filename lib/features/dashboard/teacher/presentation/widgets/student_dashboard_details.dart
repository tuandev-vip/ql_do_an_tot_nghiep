import 'package:flutter/material.dart';
import 'package:ql_do_an_tot_nghiep/features/teacher_progress/presentation/screens/teacher_progress_screen.dart';

class StudentDashboardTile extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudentDashboardTile({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    bool isPending = studentData['is_pending'] == true;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TeacherProgressScreen(studentData: studentData),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentData['full_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentData['status_text'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isPending
                          ? Colors.orange.shade700
                          : Colors.grey.shade600,
                      fontWeight: isPending
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

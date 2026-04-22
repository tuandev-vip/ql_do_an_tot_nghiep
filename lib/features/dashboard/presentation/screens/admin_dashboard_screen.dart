import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/data/models/batch_model.dart';
import '../../../batch/presentation/bloc/batch_bloc.dart';
import '../../../batch/presentation/bloc/batch_state.dart';
import '../widgets/test_mode_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          "ICTU",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- VỊ TRÍ ĐẶT CỖ MÁY THỜI GIAN ---
            // Dùng BlocBuilder để lấy đợt đang mở, giúp Card tự tính deadline nhanh
            BlocBuilder<BatchBloc, BatchState>(
              builder: (context, state) {
                // 1. Lấy danh sách đợt từ bất kỳ state nào có chứa data
                List<BatchModel> batches = [];
                if (state is BatchLoaded) {
                  batches = state.batches;
                } else if (state is BatchError) {
                  batches = state.batches;
                }

                // 2. Tìm đợt đang diễn ra (hoặc đợt đầu tiên) một cách an toàn
                final activeBatch = batches.isNotEmpty
                    ? batches.firstWhere(
                        (b) => b.isClosed == 0,
                        orElse: () => batches.first,
                      )
                    : null;

                // 3. Luôn trả về TestModeCard, nếu activeBatch có data thì Dropdown sẽ tự hiện lại
                return TestModeCard(activeBatch: activeBatch);
              },
            ),

            const SizedBox(height: 24),

            // --- CÁC PHẦN THỐNG KÊ KHÁC ---
            const Text(
              "Thống kê tổng quan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Ví dụ: Grid các thông số (Số lượng SV, GV, Đề tài...)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard("Sinh viên", "150", Colors.blue),
                _buildStatCard("Giảng viên", "45", Colors.green),
                _buildStatCard("Đề tài", "120", Colors.orange),
                _buildStatCard("Hội đồng", "5", Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

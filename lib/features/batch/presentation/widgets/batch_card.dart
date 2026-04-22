import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';
import '../../data/models/batch_model.dart';
import '../bloc/batch_bloc.dart';
import '../bloc/batch_event.dart';
import 'create_batch_dialog.dart';

class BatchCard extends StatelessWidget {
  final BatchModel batch;
  const BatchCard({super.key, required this.batch});

  // Hàm hiển thị Dialog xác nhận đóng đợt
  void _showConfirmCloseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (confirmContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Xác nhận đóng đợt"),
        content: Text(
          "Bạn có chắc muốn đóng đợt '${batch.batchName}'? \n\nSau khi đóng, mọi dữ liệu sẽ bị khóa và không thể chỉnh sửa.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(confirmContext),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<BatchBloc>().add(CloseBatchEvent(batch.batchId));
              Navigator.pop(confirmContext);
            },
            child: const Text(
              "Đồng ý đóng",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isClosed = batch.isClosed == 1;

    // 1. DÙNG GIỜ TỪ CỖ MÁY THỜI GIAN
    DateTime now = TimeManager.now();

    // 2. TRUY XUẤT DEADLINE TỪ MAP
    DateTime? regDeadline = DateTime.tryParse(
      batch.deadlines["Đăng ký Giảng viên"] ?? '',
    );

    // Điều kiện cập nhật: Chưa đến hạn reg_advisor và đợt chưa bị đóng
    bool canUpdate =
        (regDeadline != null) && now.isBefore(regDeadline) && !isClosed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            batch.batchName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 12),
          _buildInfoRow("Ngày bắt đầu", batch.startDate.split(' ')[0]),
          _buildInfoRow(
            "Trạng thái",
            isClosed ? "Đã đóng" : "Đang diễn ra",
            color: isClosed ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              // NÚT ĐÓNG ĐỢT
              // ... các đoạn khác giữ nguyên ...

              // NÚT ĐÓNG ĐỢT
              Expanded(
                child: OutlinedButton(
                  onPressed: isClosed
                      ? null
                      : () {
                          // LẤY GIỜ MỚI NHẤT NGAY KHI BẤM NÚT
                          DateTime liveNow = TimeManager.now();

                          String key = "Phân Hội đồng trường";
                          String? deadlineStr = batch.deadlines[key];
                          DateTime? prevMilestone = DateTime.tryParse(
                            deadlineStr ?? '',
                          );

                          print("--- DEBUG TIME MACHINE ---");
                          print(
                            "Giờ fake thực tế lúc bấm nút: $liveNow",
                          ); // Dùng liveNow ở đây
                          print("Mốc chặn ($key): $prevMilestone");
                          print("--------------------------");

                          // So sánh bằng liveNow để lấy giờ chuẩn nhất
                          if (prevMilestone != null &&
                              liveNow.isBefore(prevMilestone)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Chưa qua hạn $key, không được đóng đợt!",
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          } else {
                            _showConfirmCloseDialog(context);
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isClosed ? Colors.grey : Colors.red,
                  ),
                  child: Text(isClosed ? "Đã đóng" : "Đóng đợt"),
                ),
              ),
              const SizedBox(width: 10),
              // NÚT CẬP NHẬT
              Expanded(
                child: ElevatedButton(
                  onPressed: canUpdate
                      ? () async {
                          final batchBloc = context.read<BatchBloc>();
                          await showDialog(
                            context: context,
                            builder: (dialogContext) => BlocProvider.value(
                              value: batchBloc,
                              child: CreateBatchDialog(batch: batch),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canUpdate ? Colors.blue : Colors.grey,
                  ),
                  child: const Text(
                    "Cập nhật",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

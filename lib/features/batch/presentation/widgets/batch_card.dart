import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              // Gọi BLoC để thực hiện đóng đợt
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
    // 1. Logic kiểm tra trạng thái đóng/mở
    bool isClosed = batch.isClosed == 1;

    // 2. Logic kiểm tra thời gian để cho phép Cập nhật
    DateTime now = DateTime.now();
    // Chuyển đổi String từ DB sang DateTime
    DateTime? regDeadline = DateTime.tryParse(batch.advisorRegDeadline);
    // Điều kiện: Chưa đến hạn reg_advisor và đợt chưa bị đóng
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
              Expanded(
                child: OutlinedButton(
                  onPressed: isClosed
                      ? null // Vô hiệu hóa nếu đã đóng
                      : () {
                          DateTime deadline = DateTime.parse(
                            batch.councilTrAssignDeadline,
                          );
                          if (now.isBefore(deadline)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Chưa qua hạn phân công hội đồng trường, chưa được đóng đợt!",
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
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                CreateBatchDialog(batch: batch),
                          );
                        }
                      : null, // Tự động xám nút nếu không thỏa mãn canUpdate
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

  // Widget hiển thị dòng thông tin chi tiết
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

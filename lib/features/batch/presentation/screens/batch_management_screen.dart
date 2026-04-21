import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/data/models/batch_model.dart';
import '../bloc/batch_bloc.dart';
import '../bloc/batch_event.dart';
import '../bloc/batch_state.dart';
import '../widgets/batch_card.dart';
import '../widgets/create_batch_dialog.dart';

class BatchManagementScreen extends StatelessWidget {
  const BatchManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BatchBloc()..add(LoadBatchesEvent()),
      child: BlocListener<BatchBloc, BatchState>(
        // LẮNG NGHE ĐỂ HIỆN THÔNG BÁO LỖI
        listener: (context, state) {
          if (state is BatchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Builder(
          builder: (innerContext) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F7F9),
              appBar: AppBar(
                backgroundColor: const Color(0xFF2196F3),
                title: const Text(
                  "QUẢN LÝ ĐỢT ĐỒ ÁN",
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeader(innerContext),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BlocBuilder<BatchBloc, BatchState>(
                        builder: (context, state) {
                          // 1. Khi đang tải dữ liệu lần đầu
                          if (state is BatchLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // 2. TỔNG HỢP DANH SÁCH HIỂN THỊ
                          // Chúng ta lấy danh sách từ cả hai trạng thái Loaded và Error
                          List<BatchModel> displayList = [];
                          if (state is BatchLoaded) {
                            displayList = state.batches;
                          } else if (state is BatchError) {
                            displayList = state
                                .batches; // Lấy danh sách cũ đi kèm trong lỗi
                          }

                          // 3. HIỂN THỊ GIAO DIỆN
                          if (displayList.isNotEmpty) {
                            return ListView.builder(
                              itemCount: displayList.length,
                              itemBuilder: (context, index) =>
                                  BatchCard(batch: displayList[index]),
                            );
                          }

                          // 4. Nếu thực sự không có đợt nào (danh sách rỗng hoàn toàn)
                          return const Center(
                            child: Text("Chưa có đợt đồ án nào"),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Tìm đợt đồ án",
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
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () async {
            // 1. Lấy cái Bloc hiện tại ra trước khi mở Dialog
            final batchBloc = context.read<BatchBloc>();

            await showDialog(
              context: context,
              builder: (dialogContext) => BlocProvider.value(
                // 2. Chuyền cái Bloc đó vào cho Dialog dùng
                value: batchBloc,
                child: const CreateBatchDialog(),
              ),
            );

            // 3. Sau khi đóng Dialog, danh sách sẽ tự cập nhật nếu BLoC đã xử lý xong
          },
          child: const Text("Tạo đợt"),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: Builder(
        // THÊM BUILDER Ở ĐÂY
        builder: (innerContext) {
          // innerContext này mới là cái nằm dưới Provider
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
                  _buildHeader(innerContext), // TRUYỀN innerContext VÀO ĐÂY
                  const SizedBox(height: 20),

                  // PHẦN BLOC BUILDER ĐỂ HIỆN DANH SÁCH
                  Expanded(
                    child: BlocBuilder<BatchBloc, BatchState>(
                      builder: (context, state) {
                        if (state is BatchLoading)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        if (state is BatchError)
                          return Center(child: Text(state.message));

                        if (state is BatchLoaded) {
                          return ListView.builder(
                            itemCount: state.batches.length,

                            itemBuilder: (context, index) =>
                                BatchCard(batch: state.batches[index]),
                          );
                        }

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
            await showDialog(
              context: context,

              builder: (context) => const CreateBatchDialog(),
            );
            // Sau khi tạo xong, gọi lại Event để load list mới
            context.read<BatchBloc>().add(LoadBatchesEvent());
          },
          child: const Text("Tạo đợt"),
        ),
      ],
    );
  }
}

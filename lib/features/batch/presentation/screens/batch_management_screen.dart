import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/data/models/batch_model.dart';
import '../bloc/batch_bloc.dart';
import '../bloc/batch_state.dart';
import '../widgets/batch_card.dart';
import '../widgets/create_batch_dialog.dart';

class BatchManagementScreen extends StatelessWidget {
  const BatchManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Không dùng BlocProvider ở đây nữa vì đã có ở MainWrapper
    return BlocListener<BatchBloc, BatchState>(
      listener: (context, state) {
        if (state is BatchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2196F3),
          title: const Text(
            "QUẢN LÝ ĐỢT ĐỒ ÁN",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2196F3),
          onPressed: () async {
            final batchBloc = context.read<BatchBloc>();
            await showDialog(
              context: context,
              builder: (dialogContext) => BlocProvider.value(
                value: batchBloc,
                child: const CreateBatchDialog(),
              ),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Tạo Đợt", style: TextStyle(color: Colors.white)),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<BatchBloc, BatchState>(
                  builder: (context, state) {
                    if (state is BatchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Lấy danh sách từ cả trạng thái Loaded và Error để tránh màn trắng
                    List<BatchModel> displayList = [];
                    if (state is BatchLoaded) displayList = state.batches;
                    if (state is BatchError) displayList = state.batches;

                    if (displayList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: displayList.length,
                        itemBuilder: (context, index) =>
                            BatchCard(batch: displayList[index]),
                      );
                    }

                    return const Center(child: Text("Chưa có đợt đồ án nào"));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 100,
      child: FloatingActionButton(
        onPressed: () async {
          final batchBloc = context.read<BatchBloc>();
          await showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: batchBloc,
              child: const CreateBatchDialog(),
            ),
          );
        },

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Icon(Icons.add), const Text("  Tạo Đợt")],
        ),
      ),
    );
  }
}

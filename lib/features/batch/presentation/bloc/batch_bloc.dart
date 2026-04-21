import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'batch_event.dart';
import 'batch_state.dart';
import '../../data/models/batch_model.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  BatchBloc() : super(BatchInitial()) {
    // Hàm phụ để lấy danh sách batches hiện tại từ State
    List<BatchModel> getCurrentBatches() {
      if (state is BatchLoaded) {
        return (state as BatchLoaded).batches;
      } else if (state is BatchError) {
        return (state as BatchError).batches;
      }
      return [];
    }

    // 1. TẢI DANH SÁCH
    on<LoadBatchesEvent>((event, emit) async {
      final currentBatches = getCurrentBatches();
      emit(BatchLoading());
      try {
        final response = await http.get(
          Uri.parse(
            "http://192.168.1.109/ql_do_an_api/api/batch/get_batches.php",
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            List<BatchModel> batches = (data['data'] as List)
                .map((e) => BatchModel.fromJson(e))
                .toList();
            emit(BatchLoaded(batches));
          } else {
            emit(BatchError(data['message'], batches: currentBatches));
          }
        } else {
          emit(
            BatchError(
              "Lỗi Server: ${response.statusCode}",
              batches: currentBatches,
            ),
          );
        }
      } catch (e) {
        emit(BatchError("Lỗi kết nối server!", batches: currentBatches));
      }
    });

    // 2. ĐÓNG ĐỢT
    on<CloseBatchEvent>((event, emit) async {
      final currentBatches = getCurrentBatches();
      try {
        final response = await http.post(
          Uri.parse(
            "http://192.168.1.109/ql_do_an_api/api/batch/close_batch.php",
          ),
          body: {"batch_id": event.batchId},
        );

        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          add(LoadBatchesEvent());
        } else {
          emit(BatchError(data['message'], batches: currentBatches));
        }
      } catch (e) {
        emit(
          BatchError("Không thể thực hiện đóng đợt!", batches: currentBatches),
        );
      }
    });

    // 3. TẠO ĐỢT MỚI
    on<CreateBatchEvent>((event, emit) async {
      final currentBatches = getCurrentBatches();
      try {
        final response = await http.post(
          Uri.parse(
            "http://192.168.1.109/ql_do_an_api/api/batch/create_batch.php",
          ),
          body: {
            "batch_name": event.batchName,
            "template_id": event.templateId,
          },
        );
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          add(LoadBatchesEvent());
        } else {
          emit(BatchError(data['message'], batches: currentBatches));
        }
      } catch (e) {
        emit(BatchError("Lỗi kết nối khi tạo đợt!", batches: currentBatches));
      }
    });

    // 4. CẬP NHẬT ĐỢT
    on<UpdateBatchEvent>((event, emit) async {
      final currentBatches = getCurrentBatches();
      try {
        final response = await http.post(
          Uri.parse(
            "http://192.168.1.109/ql_do_an_api/api/batch/update_batch.php",
          ),
          body: {
            "batch_id": event.batchId,
            "batch_name": event.batchName,
            "template_id": event.templateId,
          },
        );
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          add(LoadBatchesEvent());
        } else {
          emit(BatchError(data['message'], batches: currentBatches));
        }
      } catch (e) {
        emit(BatchError("Lỗi kết nối khi cập nhật!", batches: currentBatches));
      }
    });
  }
}

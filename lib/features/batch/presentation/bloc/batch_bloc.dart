import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'batch_event.dart';
import 'batch_state.dart';
import '../../data/models/batch_model.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  BatchBloc() : super(BatchInitial()) {
    on<LoadBatchesEvent>((event, emit) async {
      emit(BatchLoading());
      try {
        final response = await http.get(
          Uri.parse(
            "http://192.168.1.109/ql_do_an_api/api/batch/get_batches.php",
          ),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<BatchModel> batches = (data['data'] as List)
              .map((e) => BatchModel.fromJson(e))
              .toList();
          emit(BatchLoaded(batches));
        } else {
          emit(BatchError(data['message']));
        }
      } catch (e) {
        emit(BatchError("Lỗi kết nối server!"));
      }
    });
  }
}

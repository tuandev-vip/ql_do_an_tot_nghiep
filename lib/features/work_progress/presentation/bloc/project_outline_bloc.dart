import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ql_do_an_tot_nghiep/core/untils/time_manager.dart';

import '../../../../core/constants/app_urls.dart';
import '../../data/models/project_outline_model.dart';
import 'project_outline_event.dart';
import 'project_outline_state.dart';

class ProjectOutlineBloc
    extends Bloc<ProjectOutlineEvent, ProjectOutlineState> {
  ProjectOutlineBloc() : super(OutlineInitial()) {
    // 1. XỬ LÝ SỰ KIỆN LẤY DỮ LIỆU ĐỀ CƯƠNG
    on<FetchProjectOutline>((event, emit) async {
      emit(OutlineLoading());
      try {
        final response = await http.get(
          Uri.parse(
            "${AppUrls.urlGetProjectOutline}?student_id=${event.studentId}",
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            emit(OutlineLoaded(ProjectOutlineModel.fromJson(data['data'])));
          } else {
            emit(OutlineError(data['message']));
          }
        } else {
          emit(OutlineError("Lỗi kết nối máy chủ"));
        }
      } catch (e) {
        emit(OutlineError("Lỗi hệ thống: $e"));
      }
    });

    // 2. XỬ LÝ SỰ KIỆN CẬP NHẬT ĐỀ CƯƠNG (CÓ UPLOAD FILE)
    on<UpdateProjectOutline>((event, emit) async {
      emit(OutlineUpdating());
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
            "${AppUrls.urlUpdateProjectOutline}?fake_time=${TimeManager.now().millisecondsSinceEpoch ~/ 1000}",
          ),
        );

        // Gửi các trường văn bản
        request.fields['student_id'] = event.studentId;
        request.fields['topic_direction'] = event.topicDirection;
        request.fields['topic_name'] = event.topicName;

        // LOGIC CHIA NHÁNH GỬI FILE THÔNG MINH
        if (kIsWeb) {
          // Xử lý cho trình duyệt WEB (Dùng Byte)
          if (event.fileBytes != null && event.fileName != null) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'outline_file',
                event.fileBytes!,
                filename: event.fileName!,
              ),
            );
          }
        } else {
          // Xử lý cho ANDROID / iOS (Dùng Path)
          if (event.filePath != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'outline_file',
                event.filePath!,
              ),
            );
          }
        }

        // Bắn request đi
        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var decodedData = json.decode(responseData);

        if (response.statusCode == 200 && decodedData['status'] == 'success') {
          emit(OutlineUpdateSuccess(decodedData['message']));
        } else {
          emit(
            OutlineUpdateFailure(
              decodedData['message'] ?? 'Lỗi không xác định',
            ),
          );
        }
      } catch (e) {
        emit(OutlineUpdateFailure("Lỗi hệ thống: $e"));
      }
    });
  }
}

import '../../data/models/batch_model.dart';

abstract class BatchState {}

class BatchInitial extends BatchState {}

class BatchLoading extends BatchState {}

class BatchLoaded extends BatchState {
  final List<BatchModel> batches;
  BatchLoaded(this.batches);
}

class BatchError extends BatchState {
  final String message;
  final List<BatchModel> batches;
  BatchError(this.message, {this.batches = const []});
}

abstract class BatchEvent {}

class CreateBatchEvent extends BatchEvent {
  final String batchName;
  final String templateId;
  CreateBatchEvent(this.batchName, this.templateId);
}

class LoadBatchesEvent extends BatchEvent {}

class CloseBatchEvent extends BatchEvent {
  final String batchId;
  CloseBatchEvent(this.batchId);
}

class UpdateBatchEvent extends BatchEvent {
  final String batchId;
  final String batchName;
  final String templateId;
  UpdateBatchEvent(this.batchId, this.batchName, this.templateId);
}

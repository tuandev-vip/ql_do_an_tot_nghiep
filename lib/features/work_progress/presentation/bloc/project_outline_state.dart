import '../../data/models/project_outline_model.dart';

// state đề tài
abstract class ProjectOutlineState {}

class OutlineInitial extends ProjectOutlineState {}

class OutlineLoading extends ProjectOutlineState {}

class OutlineLoaded extends ProjectOutlineState {
  final ProjectOutlineModel outline;
  OutlineLoaded(this.outline);
}

class OutlineError extends ProjectOutlineState {
  final String message;
  OutlineError(this.message);
}

// state của upload đề cương
class OutlineUpdating extends ProjectOutlineState {}

class OutlineUpdateSuccess extends ProjectOutlineState {
  final String message;
  OutlineUpdateSuccess(this.message);
}

class OutlineUpdateFailure extends ProjectOutlineState {
  final String message;
  OutlineUpdateFailure(this.message);
}

import 'package:collabo/features/workspace/data/workspace_model.dart';

abstract class WorkspaceStates {}

class WorkspaceInitStates extends WorkspaceStates {}

class WorkspaceLoadingStates extends WorkspaceStates {}

class WorkspaceSuccessStates extends WorkspaceStates {
  final List<Workspace> workSpaceData;

  WorkspaceSuccessStates(this.workSpaceData);
}

class WorkspaceErrorStates extends WorkspaceStates {
  final String message;

  WorkspaceErrorStates({required this.message});
}

class WorkspaceFailedJoiningStates extends WorkspaceStates {
  final String message;

  WorkspaceFailedJoiningStates({required this.message});
}

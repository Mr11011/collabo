import '../data/task_model.dart';

abstract class TaskStates {}

class TaskInitialState extends TaskStates {}

class TaskLoadingState extends TaskStates {}

class TaskSuccessState extends TaskStates {
  final List<Task> tasks;

  TaskSuccessState(this.tasks);
}

class TaskCreatedState extends TaskStates {}

class TaskErrorState extends TaskStates {
  final String message;

  TaskErrorState({required this.message});
}

class TaskDeletedState extends TaskStates {}

class TaskUpdatedState extends TaskStates {}

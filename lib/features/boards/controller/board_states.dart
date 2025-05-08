import '../data/board_model.dart';

abstract class BoardStates {}

class BoardInitState extends BoardStates {}

class BoardLoadingState extends BoardStates {}

class BoardSuccessState extends BoardStates {
  final List<Board> boards;

  BoardSuccessState(this.boards);
}

class BoardCreatedState extends BoardStates {

}

class BoardErrorState extends BoardStates {
  final String message;

  BoardErrorState({required this.message});
}

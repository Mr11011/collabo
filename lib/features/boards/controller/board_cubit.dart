import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/utils/id_generator.dart';
import '../data/board_model.dart';
import 'board_states.dart';

class BoardCubit extends Cubit<BoardStates> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  BoardCubit({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       super(BoardInitState());

  Future<void> createBoard(
    String workspaceId,
    String name,
    String description,
  ) async {
    // emit(BoardLoadingState());
    // Fetch the current user
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(BoardErrorState(message: "User not found"));
      return;
    }
    final boardId = generateShortId(10);

    final board = Board(
      boardId: boardId,
      boardName: name,
      boardDescription: description,
      createdAt: Timestamp.now(),
    );
    try {
      // Check if the board ID already exists
      final existingBoard =
          await _firestore
              .collection('workspaces')
              .doc(workspaceId)
              .collection('boards')
              .doc(boardId)
              .get();
      if (existingBoard.exists) {
        emit(BoardErrorState(message: "Board ID already exists"));
        return;
      }
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('boards')
          .doc(board.boardId)
          .set(board.toMap());
      emit(BoardCreatedState());

      await fetchBoards(
        workspaceId,
      ); // Fetch boards after creating a new one to update the UI
    } catch (e) {
      emit(BoardErrorState(message: "Failed to create board"));
      debugPrint(e.toString());

    }
  }

  Future<void> fetchBoards(String workspaceId) async {
    emit(BoardLoadingState());
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(BoardErrorState(message: "User not found"));
      return;
    }
    try {
      final querySnapshot =
          await _firestore
              .collection('workspaces')
              .doc(workspaceId)
              .collection('boards')
              .orderBy('createdAt', descending: true)
              .get();
      if (querySnapshot.docs.isEmpty) {
        emit(BoardErrorState(message: "No boards found in this workspace"));
        return;
      }

      final boards =
          querySnapshot.docs.map((doc) => Board.fromMap(doc.data())).toList();
      emit(BoardSuccessState(boards));
    } catch (e) {
      emit(BoardErrorState(message: "Failed to fetch boards"));
      debugPrint(e.toString());

    }
  }
}

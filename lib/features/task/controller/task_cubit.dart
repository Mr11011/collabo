import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabo/core/utils/id_generator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/task_model.dart';
import 'task_states.dart';

class TaskCubit extends Cubit<TaskStates> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  TaskCubit({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       super(TaskInitialState());

  Future<void> createTask({
    required String workspaceId,
    required String boardId,
    required String title,
    required String description,
    required String status,
    DateTime? dueDate,
  }) async {
    try {
      emit(TaskLoadingState());

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(TaskErrorState(message: 'User not authenticated'));
        return;
      }
      final taskId = generateShortId(4);
      final task = Task(
        taskId: taskId,
        boardId: boardId,
        title: title,
        description: description,
        status: status,
        assignedUserIds: [user.uid],
        dueDate: dueDate != null ? Timestamp.fromDate(dueDate) : null,
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection("workspaces")
          .doc(workspaceId)
          .collection('boards')
          .doc(boardId)
          .collection('tasks')
          .doc(taskId)
          .set(task.toMap());
      emit(TaskCreatedState());
      await fetchTasks(workspaceId, boardId);
    } catch (e) {
      emit(TaskErrorState(message: "Error creating task"));
      debugPrint(e.toString());
    }
  }

  Future<void> fetchTasks(String workspaceId, String boardId) async {
    try {
      emit(TaskLoadingState());
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(TaskErrorState(message: 'User not authenticated'));
        return;
      }

      final querySnapshot =
          await _firestore
              .collection('workspaces')
              .doc(workspaceId)
              .collection('boards')
              .doc(boardId)
              .collection('tasks')
              .orderBy('createdAt', descending: true)
              .get();
      // if (querySnapshot.docs.isEmpty) {
      //   emit(TaskErrorState(message: 'No tasks found'));
      //   return;
      // }
      final tasks =
          querySnapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
      emit(TaskSuccessState(tasks));
    } catch (e) {
      emit(TaskErrorState(message: "Error fetching tasks"));
      debugPrint(e.toString());
    }
  }

  Future<void> updateTaskStatus({
    required String workspaceId,
    required String boardId,
    required String taskId,
    required String status,
  }) async {
    try {
      emit(TaskLoadingState());
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(TaskErrorState(message: 'User not authenticated'));
        return;
      }
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('boards')
          .doc(boardId)
          .collection('tasks')
          .doc(taskId)
          .update({'status': status});
      await fetchTasks(workspaceId, boardId);
    } catch (e) {
      emit(TaskErrorState(message: 'Error updating task status'));
      debugPrint(e.toString());
    }
  }

  Future<void> deleteTask({
    required String workspaceId,
    required String boardId,
    required String taskId,
  }) async {
    try {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('boards')
          .doc(boardId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      emit(TaskDeletedState());
      await fetchTasks(workspaceId, boardId);
    } catch (e) {
      emit(TaskErrorState(message: "Failed to delete task"));
    }
  }
}

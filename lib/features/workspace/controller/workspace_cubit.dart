import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabo/features/workspace/controller/workspace_states.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/workspace_model.dart';

class WorkSpaceCubit extends Cubit<WorkspaceStates> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  WorkSpaceCubit({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       super(WorkspaceInitStates());

  Future<void> createWorkSpace(
    String name,
    String description,
    String workspaceID,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(WorkspaceErrorStates(message: "User not found"));
      return;
    }
    final String ownerID = user.uid;
    final workspace = Workspace(
      workspaceId: workspaceID,
      name: name,
      description: description,
      ownerId: ownerID,
      memberIds: [ownerID],
      createdAt: Timestamp.now(),
    );

    try {
      await _firestore
          .collection('workspaces')
          .doc(workspaceID)
          .set(workspace.toMap());
      await fetchWorkspaces(); // Fetch workspaces after creating a new one to update the UI
    } catch (e) {
      emit(WorkspaceErrorStates(message: "Failed to create workspace"));
    }
  }

  Future<void> fetchWorkspaces() async {
    emit(WorkspaceLoadingStates());
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(WorkspaceErrorStates(message: "User not found"));
      return;
    }
    try {
      final querySnapshot =
          await _firestore
              .collection('workspaces')
              .where('memberIds', arrayContains: user.uid)
              .orderBy('createdAt', descending: true)
              .get();
      if (querySnapshot.docs.isEmpty) {
        emit(WorkspaceErrorStates(message: "No workspaces found"));
        return;
      }
      final workspaces =
          querySnapshot.docs
              .map((doc) => Workspace.fromMap(doc.data()))
              .toList();
      emit(WorkspaceSuccessStates(workspaces));
    } catch (e) {
      emit(WorkspaceErrorStates(message: "Failed to fetch workspaces"));
    }
  }

  Future<void> joinWorkspace(String workspaceId) async {
    try {
      emit(WorkspaceLoadingStates());
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('User not found');

      await _firestore.collection('workspaces').doc(workspaceId).update({
        'memberIds': FieldValue.arrayUnion([user.uid]),
      });

      // Refresh the workspaces list
      await fetchWorkspaces();
    } catch (e) {
      emit(WorkspaceFailedJoiningStates(message: 'Failed to join workspace'));
    }
  }
}

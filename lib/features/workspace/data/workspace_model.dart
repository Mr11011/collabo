// features/workspace/data/workspace_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Workspace {
  final String workspaceId;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final Timestamp createdAt;

  Workspace({
    required this.workspaceId,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
  });

  // Convert Workspace to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'workspaceId': workspaceId,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'createdAt': createdAt,
    };
  }

  // Create Workspace from Firestore document
  factory Workspace.fromMap(Map<String, dynamic> map) {
    return Workspace(
      workspaceId: map['workspaceId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      ownerId: map['ownerId'] as String,
      memberIds: List<String>.from(map['memberIds'] as List<dynamic>),
      createdAt: map['createdAt'] as Timestamp,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String taskId;
  final String boardId;
  final String title;
  final String description;
  final String status; // 'todo', 'inProgress', 'done'
  final Timestamp? dueDate;
  final List<String> assignedUserIds;
  final Timestamp createdAt;

  Task({
    required this.taskId,
    required this.boardId,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    required this.assignedUserIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'boardId': boardId,
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate,
      'assignedUserIds': assignedUserIds,
      'createdAt': createdAt,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['taskId'] as String,
      boardId: map['boardId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      dueDate: map['dueDate'] as Timestamp?,
      assignedUserIds: List<String>.from(
        map['assignedUserIds'] as List<dynamic>,
      ),
      createdAt: map['createdAt'] as Timestamp,
    );
  }
}

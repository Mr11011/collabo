import 'package:cloud_firestore/cloud_firestore.dart';

class Board {
  final String boardName;
  final String boardId;
  final String boardDescription;
  final Timestamp createdAt;

  Board({
    required this.boardName,
    required this.boardId,
    required this.boardDescription,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'boardName': boardName,
      'boardId': boardId,
      'boardDescription': boardDescription,
      'createdAt': createdAt,
    };
  }

  factory Board.fromMap(Map<String, dynamic> map) {
    return Board(
      boardName: map['boardName'] as String,
      boardId: map['boardId'] as String,
      boardDescription: map['boardDescription'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }
}

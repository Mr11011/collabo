import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  final String email;
  final String username;
  final String title;
  final String phone;
  final String? profilePictureUrl;
  final Timestamp? createdAt;

  UserData({
    required this.uid,
    required this.email,
    required this.username,
    required this.title,
    required this.phone,
    this.profilePictureUrl,
    this.createdAt,
  });

  // Convert UserData to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'title': title,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Create UserData from Firestore document
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      uid: map['uid'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      title: map['title'] as String,
      phone: map['phone'] as String,
      profilePictureUrl: map['profilePictureUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
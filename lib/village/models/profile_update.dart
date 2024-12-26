import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileUpdate {
  final String userId;
  final String oldName;
  final String newName;
  final String email;
  final DateTime updatedAt;

  ProfileUpdate({
    required this.userId,
    required this.oldName,
    required this.newName,
    required this.email,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'oldName': oldName,
      'newName': newName,
      'email': email,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ProfileUpdate.fromMap(Map<String, dynamic> map) {
    return ProfileUpdate(
      userId: map['userId'] as String,
      oldName: map['oldName'] as String,
      newName: map['newName'] as String,
      email: map['email'] as String,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

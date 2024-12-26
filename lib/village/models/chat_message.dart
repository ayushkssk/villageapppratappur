import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String message;
  final String senderId;
  final String senderName;
  final String userType;
  final Timestamp timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.userType,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'userType': userType,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      message: map['message'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      userType: map['userType'] ?? '',
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  DateTime get dateTime => timestamp.toDate();
}

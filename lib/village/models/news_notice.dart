import 'package:cloud_firestore/cloud_firestore.dart';

class NewsNotice {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;

  NewsNotice({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  factory NewsNotice.fromMap(Map<String, dynamic> map, String id) {
    return NewsNotice(
      id: id,
      title: map['title'] ?? 'No Title',
      message: map['message'] ?? 'No Message',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

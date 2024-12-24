import 'package:cloud_firestore/cloud_firestore.dart';

class NewsUpdate {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime timestamp;

  NewsUpdate({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
  });

  factory NewsUpdate.fromMap(Map<String, dynamic> map) {
    return NewsUpdate(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

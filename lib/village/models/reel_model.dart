import 'package:cloud_firestore/cloud_firestore.dart';

class ReelModel {
  final String id;
  final String videoUrl;
  final String description;
  final DateTime timestamp;
  final int likes;
  final int views;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.description,
    required this.timestamp,
    this.likes = 0,
    this.views = 0,
  });

  // Create ReelModel from Firestore document
  factory ReelModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReelModel(
      id: doc.id,
      videoUrl: data['videoUrl'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      views: data['views'] ?? 0,
    );
  }

  // Convert ReelModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'views': views,
    };
  }
}

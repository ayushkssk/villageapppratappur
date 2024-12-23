import 'package:cloud_firestore/cloud_firestore.dart';

class ReelModel {
  final String id;
  final String videoUrl;
  final String userAvatar;
  final String username;
  final String description;
  final int likes;
  final int comments;
  final Timestamp createdAt;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.userAvatar,
    required this.username,
    required this.description,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory ReelModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReelModel(
      id: doc.id,
      videoUrl: data['videoUrl'] ?? '',
      userAvatar: data['userAvatar'] ?? 'assets/images/village_logo.png',
      username: data['username'] ?? 'Unknown User',
      description: data['description'] ?? '',
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'userAvatar': userAvatar,
      'username': username,
      'description': description,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt,
    };
  }
}

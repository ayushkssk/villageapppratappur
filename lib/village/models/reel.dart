import 'package:cloud_firestore/cloud_firestore.dart';

class Reel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final Timestamp timestamp;
  final String authorId;
  final String authorName;
  final int likes;
  final List<String> tags;

  Reel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.timestamp,
    required this.authorId,
    required this.authorName,
    this.likes = 0,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'timestamp': timestamp,
      'authorId': authorId,
      'authorName': authorName,
      'likes': likes,
      'tags': tags,
    };
  }

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      timestamp: json['timestamp'] as Timestamp? ?? Timestamp.now(),
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

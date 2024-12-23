import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/reel_model.dart';

class ReelsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all reels
  Stream<List<ReelModel>> getReels() {
    return _firestore
        .collection('reels')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReelModel.fromFirestore(doc)).toList();
    });
  }

  // Upload a new reel
  Future<String> uploadReel({
    required File videoFile,
    required String username,
    required String description,
  }) async {
    try {
      // 1. Upload video to Firebase Storage
      String fileName = 'reels/${DateTime.now().millisecondsSinceEpoch}.mp4';
      UploadTask uploadTask = _storage.ref(fileName).putFile(videoFile);
      
      TaskSnapshot snapshot = await uploadTask;
      String videoUrl = await snapshot.ref.getDownloadURL();

      // 2. Create reel document in Firestore
      DocumentReference doc = await _firestore.collection('reels').add({
        'videoUrl': videoUrl,
        'username': username,
        'description': description,
        'likes': 0,
        'comments': 0,
        'createdAt': Timestamp.now(),
        'userAvatar': 'assets/images/village_logo.png', // Default avatar
      });

      return doc.id;
    } catch (e) {
      throw Exception('Failed to upload reel: $e');
    }
  }

  // Like/Unlike a reel
  Future<void> toggleLike(String reelId, bool isLiked) async {
    await _firestore.collection('reels').doc(reelId).update({
      'likes': FieldValue.increment(isLiked ? 1 : -1),
    });
  }

  // Add comment
  Future<void> addComment(String reelId, String comment) async {
    await _firestore.collection('reels').doc(reelId).collection('comments').add({
      'text': comment,
      'createdAt': Timestamp.now(),
      'username': 'Current User', // Replace with actual user's name
    });

    await _firestore.collection('reels').doc(reelId).update({
      'comments': FieldValue.increment(1),
    });
  }

  // Get comments for a reel
  Stream<QuerySnapshot<Map<String, dynamic>>> getComments(String reelId) {
    return _firestore
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

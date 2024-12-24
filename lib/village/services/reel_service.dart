import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reel_model.dart';

class ReelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reels';

  // Add new reel
  Future<void> addReel({
    required String videoUrl,
    required String description,
    required String username,
    String userAvatar = 'assets/images/village_logo.png',
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'videoUrl': videoUrl,
        'description': description,
        'username': username,
        'userAvatar': userAvatar,
        'likes': 0,
        'comments': 0,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add reel: $e');
    }
  }

  // Get all reels
  Stream<List<ReelModel>> getReels() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReelModel.fromFirestore(doc)).toList();
    });
  }

  // Delete reel
  Future<void> deleteReel(String reelId) async {
    try {
      await _firestore.collection(_collection).doc(reelId).delete();
    } catch (e) {
      throw Exception('Failed to delete reel: $e');
    }
  }
}

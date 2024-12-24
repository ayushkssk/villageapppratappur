import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reel_model.dart';

class ReelService {
  final CollectionReference _reelsCollection =
      FirebaseFirestore.instance.collection('reels');

  // Get all reels
  Stream<List<ReelModel>> getReels() {
    return _reelsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReelModel.fromFirestore(doc)).toList();
    });
  }

  // Add a new reel
  Future<void> addReel(String videoUrl, String description) async {
    await _reelsCollection.add({
      'videoUrl': videoUrl,
      'description': description,
      'timestamp': Timestamp.now(),
      'likes': 0,
      'views': 0,
    });
  }

  // Update likes
  Future<void> updateLikes(String reelId, bool increment) async {
    try {
      DocumentReference reelRef = _reelsCollection.doc(reelId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(reelRef);
        
        if (!snapshot.exists) {
          throw Exception('Reel does not exist!');
        }
        
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentLikes = data['likes'] ?? 0;
        
        transaction.update(reelRef, {
          'likes': increment ? currentLikes + 1 : currentLikes - 1
        });
      });
    } catch (e) {
      print('Error updating likes: $e');
      throw e;
    }
  }

  // Update views
  Future<void> updateViews(String reelId) async {
    try {
      DocumentReference reelRef = _reelsCollection.doc(reelId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(reelRef);
        
        if (!snapshot.exists) {
          throw Exception('Reel does not exist!');
        }
        
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentViews = data['views'] ?? 0;
        
        transaction.update(reelRef, {
          'views': currentViews + 1
        });
      });
    } catch (e) {
      print('Error updating views: $e');
      throw e;
    }
  }
}

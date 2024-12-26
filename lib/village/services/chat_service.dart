import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collectionName = 'chats';
  final String _typingCollectionName = 'typing_status';

  // Get messages stream
  Stream<List<ChatMessage>> getMessages() {
    return _firestore
        .collection(_collectionName)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => 
        ChatMessage.fromMap(doc.data(), doc.id)
      ).toList();
    });
  }

  // Get typing status stream
  Stream<Map<String, bool>> getTypingStatus() {
    return _firestore
        .collection(_typingCollectionName)
        .snapshots()
        .map((snapshot) {
      Map<String, bool> typingStatus = {};
      for (var doc in snapshot.docs) {
        typingStatus[doc.id] = doc.data()['isTyping'] ?? false;
      }
      return typingStatus;
    });
  }

  // Set typing status
  Future<void> setTypingStatus(String userId, bool isTyping) async {
    await _firestore
        .collection(_typingCollectionName)
        .doc(userId)
        .set({'isTyping': isTyping}, SetOptions(merge: true));
  }

  // Send text message
  Future<void> sendMessage({
    required String message,
    required String senderId,
    required String senderName,
    required String userType,
  }) async {
    final chatMessage = ChatMessage(
      id: '',
      message: message,
      senderId: senderId,
      senderName: senderName,
      userType: userType,
      timestamp: Timestamp.now(),
    );

    await _firestore.collection(_collectionName).add(chatMessage.toMap());
    await setTypingStatus(senderId, false);
  }

  // Delete message if it's within 12 hours and belongs to the user
  Future<bool> canDeleteMessage(String messageId, String userId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(messageId).get();
      if (!doc.exists) return false;

      final message = ChatMessage.fromMap(doc.data()!, doc.id);
      
      // Check if message belongs to user
      if (message.senderId != userId) return false;

      // Check if message is within 12 hours
      final now = DateTime.now();
      final messageTime = message.dateTime;
      final difference = now.difference(messageTime);
      
      return difference.inHours <= 12;
    } catch (e) {
      return false;
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId, String userId) async {
    try {
      if (await canDeleteMessage(messageId, userId)) {
        await _firestore.collection(_collectionName).doc(messageId).delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get messages for a specific user
  Stream<List<ChatMessage>> getUserMessages(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => 
        ChatMessage.fromMap(doc.data(), doc.id)
      ).toList();
    });
  }

  // Get last message
  Future<ChatMessage?> getLastMessage() async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return ChatMessage.fromMap(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  // Get messages count
  Future<int> getMessagesCount() async {
    final snapshot = await _firestore.collection(_collectionName).count().get();
    return snapshot.count ?? 0;
  }
}

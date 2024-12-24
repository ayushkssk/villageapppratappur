import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get messages stream
  Stream<List<Message>> getMessages() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Send text message
  Future<void> sendMessage(String content, String senderId, String senderName) async {
    final message = Message(
      id: '',
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    await _firestore.collection('messages').add(message.toMap());
  }

  // Send image message
  Future<void> sendImageMessage(File image, String senderId, String senderName) async {
    final ref = _storage.ref().child('chat_images/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = ref.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final message = Message(
      id: '',
      senderId: senderId,
      senderName: senderName,
      content: 'Image',
      type: MessageType.image,
      timestamp: DateTime.now(),
      mediaUrl: downloadUrl,
    );

    await _firestore.collection('messages').add(message.toMap());
  }

  // Send audio message
  Future<void> sendAudioMessage(File audio, int duration, String senderId, String senderName) async {
    final ref = _storage.ref().child('chat_audio/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = ref.putFile(audio);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final message = Message(
      id: '',
      senderId: senderId,
      senderName: senderName,
      content: 'Audio message',
      type: MessageType.audio,
      timestamp: DateTime.now(),
      mediaUrl: downloadUrl,
      audioDuration: duration,
    );

    await _firestore.collection('messages').add(message.toMap());
  }

  // Send file message
  Future<void> sendFileMessage(File file, String fileName, int fileSize, String senderId, String senderName) async {
    final ref = _storage.ref().child('chat_files/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final message = Message(
      id: '',
      senderId: senderId,
      senderName: senderName,
      content: 'File',
      type: MessageType.file,
      timestamp: DateTime.now(),
      mediaUrl: downloadUrl,
      fileName: fileName,
      fileSize: fileSize,
    );

    await _firestore.collection('messages').add(message.toMap());
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'isRead': true,
    });
  }
}

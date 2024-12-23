import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import '../../../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty && imageUrl == null) return;

    final message = Message(
      id: '',
      senderId: widget.userId,
      senderName: widget.userName,
      content: messageText,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );

    try {
      await _firestore.collection('messages').add(message.toMap());
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedFile == null) {
        throw Exception('Failed to compress image');
      }

      final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('chat_images/$fileName');

      final uploadTask = ref.putFile(
        File(compressedFile.path),
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      await _sendMessage(imageUrl: imageUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMessageBubble(Message message) {
    final isCurrentUser = message.senderId == widget.userId;
    final bubbleColor = isCurrentUser ? Colors.green[100] : Colors.grey[200];
    final alignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(),
                            body: Center(
                              child: InteractiveViewer(
                                child: Image.network(message.imageUrl!),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                  ),
                if (message.content.isNotEmpty)
                  Text(
                    message.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs
                    .map((doc) => Message.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _isLoading ? null : _pickAndUploadImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isLoading ? null : () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

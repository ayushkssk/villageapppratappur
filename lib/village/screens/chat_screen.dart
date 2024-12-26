import 'dart:async';
import 'dart:math' show pi, sin;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../auth/providers/auth_provider.dart';
import '../widgets/village_pattern_painter.dart';
import '../utils/color_generator.dart';
import 'home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  Timer? _typingTimer;
  bool _isTyping = false;
  Map<String, bool> _typingUsers = {};
  Timer? _restartReminderTimer;
  bool _showRestartReminder = false;

  @override
  void initState() {
    super.initState();
    _setupTypingListener();
    _setupRestartReminder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _restartReminderTimer?.cancel();
    super.dispose();
  }

  void _setupTypingListener() {
    _messageController.addListener(() {
      final isCurrentlyTyping = _messageController.text.isNotEmpty;
      if (isCurrentlyTyping != _isTyping) {
        _isTyping = isCurrentlyTyping;
        _handleTypingStatus();
      }
    });
  }

  void _handleTypingStatus() {
    final authProvider = context.read<VillageAuthProvider>();
    final user = authProvider.user;
    
    if (user == null) return;

    if (_isTyping) {
      _typingTimer?.cancel();
      _chatService.setTypingStatus(user.uid, true);
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _chatService.setTypingStatus(user.uid, false);
        _isTyping = false;
      });
    } else {
      _chatService.setTypingStatus(user.uid, false);
    }
  }

  void _setupRestartReminder() {
    _restartReminderTimer = Timer(const Duration(hours: 4), () {
      if (mounted) {
        setState(() {
          _showRestartReminder = true;
        });
      }
    });
  }

  Widget _buildTypingIndicator() {
    if (_typingUsers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBE9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD7CCC8),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDotAnimation(),
                _buildDotAnimation(delay: 0.2),
                _buildDotAnimation(delay: 0.4),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getTypingText(),
            style: const TextStyle(
              color: Color(0xFF5D4037),
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotAnimation({double delay = 0.0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, sin(value * pi * 2) * 3),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF5D4037).withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _getTypingText() {
    final typingCount = _typingUsers.length;
    if (typingCount == 0) return '';
    if (typingCount == 1) {
      final name = _typingUsers.keys.first;
      return '$name टाइप कर रहे हैं...';
    }
    return '$typingCount लोग टाइप कर रहे हैं...';
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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final authProvider = context.read<VillageAuthProvider>();
    final user = authProvider.user;
    
    if (user == null) return;

    String userType = 'registered';
    if (authProvider.isDemoMode) {
      userType = 'guest';
    } else if (authProvider.isOfflineMode) {
      userType = 'offline';
    }

    setState(() => _isLoading = true);
      
    try {
      await _chatService.sendMessage(
        message: message,
        senderId: user.uid,
        senderName: user.displayNameOrEmail,
        userType: userType,
      );

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      await _showErrorSnackBar('संदेश भेजने में त्रुटि: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final authProvider = context.read<VillageAuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    try {
      final success = await _chatService.deleteMessage(messageId, user.uid);
      if (!success && mounted) {
        await _showErrorSnackBar('12 घंटे से पुराने संदेश को नहीं हटा सकते हैं');
      }
    } catch (e) {
      if (mounted) {
        await _showErrorSnackBar('संदेश हटाने में त्रुटि: $e');
      }
    }
  }

  void _showDeleteConfirmation(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFFF5F3F0),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFF795548),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'संदेश हटाएं?',
              style: TextStyle(
                color: Color(0xFF4E342E),
                fontFamily: 'Poppins',
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'क्या आप वाकई इस संदेश को हटाना चाहते हैं? यह कार्य पूर्ववत नहीं किया जा सकता है।',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'रद्द करें',
              style: TextStyle(
                color: Color(0xFF5D4037),
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF33691E).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'हटाएं',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteMessage(messageId);
    }
  }

  Future<void> _showErrorSnackBar(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Color _getMessageColor(String userType, bool isCurrentUser, String userId) {
    if (isCurrentUser) {
      return const Color(0xFF2E7D32); // Keep current user's messages consistent
    }
    if (userType == 'offline') {
      return const Color(0xFF795548); // Keep offline users brown
    }
    return ColorGenerator.getColorForUser(userId);
  }

  Widget _buildMessage(ChatMessage message, bool isCurrentUser, int index, List<ChatMessage> messages) {
    final now = DateTime.now();
    final messageTime = message.dateTime;
    final canDelete = isCurrentUser && now.difference(messageTime).inHours <= 12;
    final timeStr = DateFormat('HH:mm').format(messageTime);
    final isToday = messageTime.day == now.day && 
                    messageTime.month == now.month && 
                    messageTime.year == now.year;
    final isYesterday = messageTime.day == now.day - 1 && 
                       messageTime.month == now.month && 
                       messageTime.year == now.year;
    
    String dateStr;
    if (isToday) {
      dateStr = 'आज';
    } else if (isYesterday) {
      dateStr = 'कल';
    } else {
      dateStr = DateFormat('d MMM').format(messageTime);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (index == 0 || _shouldShowDateDivider(messages[index - 1].dateTime, messageTime))
          Column(
            children: <Widget>[
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEBE9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD7CCC8),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      color: Color(0xFF4E342E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        Align(
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              margin: EdgeInsets.only(
                left: isCurrentUser ? 64 : 8,
                right: isCurrentUser ? 8 : 64,
                bottom: 4,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _getMessageColor(message.userType, isCurrentUser, message.senderId),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (!isCurrentUser)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              message.senderName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.95),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            if (message.userType == 'offline') ...[
                              const SizedBox(width: 4),
                              Text(
                                '(अतिथि उपयोगकर्ता)',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: canDelete ? 24 : 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              message.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.3,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (canDelete)
                        Positioned(
                          right: -8,
                          bottom: -8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _showDeleteConfirmation(message.id),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _shouldShowDateDivider(DateTime previous, DateTime current) {
    return previous.year != current.year ||
           previous.month != current.month ||
           previous.day != current.day;
  }

  Widget _buildRestartReminder() {
    if (!_showRestartReminder) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFFBE9E7),
            title: const Row(
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFFE64A19),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'ऐप रीस्टार्ट करें',
                  style: TextStyle(
                    color: Color(0xFFE64A19),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            content: const Text(
              'क्या आप वाकई ऐप को रीस्टार्ट करना चाहते हैं?',
              style: TextStyle(
                color: Color(0xFFE64A19),
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'रद्द करें',
                  style: TextStyle(
                    color: Color(0xFFE64A19),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Restart.restartApp();
                },
                child: const Text(
                  'रीस्टार्ट करें',
                  style: TextStyle(
                    color: Color(0xFFE64A19),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFBE9E7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFCCBC),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: Color(0xFFE64A19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'कृपया ऐप को रीस्टार्ट करें',
                    style: TextStyle(
                      color: Color(0xFFE64A19),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'बेहतर प्रदर्शन के लिए ऐप को रीस्टार्ट करें',
                    style: TextStyle(
                      color: Color(0xFFF4511E),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showRestartReminder = false;
                });
              },
              icon: const Icon(
                Icons.close,
                size: 18,
                color: Color(0xFFE64A19),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<VillageAuthProvider>();
    final currentUser = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF33691E),
        elevation: 0,
        title: const Text(
          'ग्राम चौपाल',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF33691E), Color(0xFF1B5E20)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFBE9E7),
              ),
              child: CustomPaint(
                painter: VillagePatternPainter(
                  color: Colors.brown,
                  opacity: 0.06,
                ),
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _chatService.getMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Color(0xFF5D4037),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'संदेश लोड करने में त्रुटि\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF5D4037),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33691E)),
                        ),
                      );
                    }

                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: const Color(0xFF5D4037).withOpacity(0.6),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'अभी तक कोई संदेश नहीं\nबातचीत शुरू करें!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (_showRestartReminder) _buildRestartReminder(),
                        _buildTypingIndicator(),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isCurrentUser = message.senderId == currentUser?.uid;
                              return _buildMessage(message, isCurrentUser, index, messages);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD7CCC8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5D4037).withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onChanged: (text) {
                              setState(() {}); // Just update UI for clear button
                            },
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5D4037),
                              fontFamily: 'Poppins',
                            ),
                            decoration: const InputDecoration(
                              hintText: 'अपना संदेश लिखें...',
                              hintStyle: TextStyle(
                                color: Color(0xFF8D6E63),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        if (_messageController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => _messageController.clear(),
                            child: Icon(
                              Icons.clear,
                              size: 16,
                              color: const Color(0xFF8D6E63).withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF33691E), Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF33691E).withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isLoading ? null : _sendMessage,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

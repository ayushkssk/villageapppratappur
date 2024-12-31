import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villageapp/village/auth/screens/login_screen.dart';
import './admin/admin_panel.dart';
import './about_village.dart';
import './emergency_services.dart';
import './government_schemes.dart';
import './grievance_portal.dart';
import './important_contacts.dart';
import './important_helplines.dart';
import './notifications.dart';
import './photo_gallery_home.dart';
import './photo_gallery_screen.dart';
import './talent_corner.dart';
import './contact_form.dart';
import './middle_school/middle_school_screen.dart';
import '../services/firestore_service.dart';
import '../models/news_update.dart';
import '../models/event.dart';
import '../models/emergency_alert.dart';
import '../models/news_notice.dart';
import 'chat_screen.dart';
import 'events_screen.dart';
import 'reels_screen.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import './main_screen.dart';
import 'government_projects/har_ghar_nal_jal.dart';
import 'news_notices.dart';
import '../widgets/login_dialog.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomBar;
  
  const HomeScreen({
    super.key,
    this.showBottomBar = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _newsUpdates = [];
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _emergencyAlerts = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  Timer? _newsScrollTimer;
  Timer? _imageSlideTimer;
  Timer? _updateSlideTimer;
  int _selectedIndex = 0;  
  final PageController _newsController = PageController(
    viewportFraction: 1.0,
    keepPage: true,
  );
  int _currentNewsIndex = 0;
  bool _isNewsScrollPaused = false;
  final List<String> _imageUrls = [
    'assets/images/middle_school/middleschool0.png',
    'assets/images/middle_school/middleschool1.png',
    'assets/images/middle_school/middleschool2.png',
    'assets/images/middle_school/middleschool3.png',
    'assets/images/middle_school/middleschool4.png',
    'assets/images/middle_school/middleschool5.png',
    'assets/images/middle_school/middleschool6.png',
    'assets/images/middle_school/middleschool7.png',
    'assets/images/middle_school/middleschool8.png',
    'assets/images/middle_school/middleschool9.png',
    'assets/images/middle_school/middleschool10.png',
    'assets/images/middle_school/middleschool11.png',
    'assets/images/middle_school/middleschool12.png',
    'assets/images/middle_school/middleschool13.png',
    'assets/images/middle_school/middleschool14.png',
  ];
  int _notificationCount = 0;
  final List<Widget> _screens = [
    const HomeScreen(showBottomBar: false),
    const ChatScreen(),
    const EventsScreen(),
    const ReelsScreen(),
  ];
  int _selectedUpdateIndex = 0;
  final PageController _updateController = PageController();
  bool _profileUpdateLoading = false;
  EmergencyAlert? _latestAlert;
  bool _isLoadingAlert = false;

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        // Chat - Show coming soon
        _handleChatTap();
        break;
      case 2:
        // Events
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventsScreen()),
        );
        break;
      case 3:
        // Reels
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReelsScreen()),
        );
        break;
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => const LoginDialog(),
    );
  }

  void _handleChatTap() {
    _showLoginDialog();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _startImageSlideTimer();
    _startUpdateAutoSlide();
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _loadData();
      _loadLatestAlert();  // Refresh emergency alerts periodically
    });
    _loadLatestAlert();
    _updateNotificationCount();

    // Listen for real-time emergency alert updates
    FirebaseFirestore.instance
        .collection('emergency_alerts')
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .handleError((error) {
          print('Firestore Error: $error');
          if (error.toString().contains('indexes?create_composite=')) {
            final indexUrl = error.toString().split('indexes?create_composite=')[1].split(' ')[0];
            print('Create index at: https://console.firebase.google.com/v1/$indexUrl');
          }
          return Stream.error(error);
        })
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final alertData = snapshot.docs.first.data();
        setState(() {
          _latestAlert = EmergencyAlert.fromMap(alertData, snapshot.docs.first.id);
        });
      } else {
        setState(() {
          _latestAlert = null;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageSlideTimer?.cancel();
    _newsController.dispose();
    _updateSlideTimer?.cancel();
    _updateController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startNewsAutoScroll() {
    _newsScrollTimer?.cancel();
    _newsScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_newsUpdates.isEmpty || _isNewsScrollPaused) return;

      if (_newsController.hasClients) {
        final nextPage = _currentNewsIndex + 1;
        
        if (nextPage >= _newsUpdates.length) {
          // Jump to start without animation when reaching the end
          _newsController.jumpToPage(0);
          _currentNewsIndex = 0;
        } else {
          // Animate to next page
          _newsController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _startImageSlideTimer() {
    _imageSlideTimer?.cancel();
    _imageSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_newsController.hasClients) {
        if (_currentNewsIndex < _imageUrls.length - 1) {
          // If not at the last image, go to next image
          _newsController.animateToPage(
            _currentNewsIndex + 1,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else {
          // If at last image, animate back to first image
          _newsController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _startUpdateAutoSlide() {
    _updateSlideTimer?.cancel();
    _updateSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_newsUpdates.isNotEmpty && mounted) {
        setState(() {
          _selectedUpdateIndex = (_selectedUpdateIndex + 1) % _newsUpdates.length;
        });
        _updateController.animateToPage(
          _selectedUpdateIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final newsSnapshot = await _firestoreService.getNewsUpdates().first;
      final eventsSnapshot = await _firestoreService.getEvents().first;
      final alertsSnapshot = await _firestoreService.getEmergencyAlerts().first;

      if (!mounted) return;

      setState(() {
        _newsUpdates = newsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'title': data['title'] ?? 'Untitled',
            'content': data['description'] ?? 'No content available',
            'imageUrl': data['imageUrl'] ?? '',
            'timestamp': (data['timestamp'] as Timestamp).toDate(),
          };
        }).toList();

        _events = eventsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'title': data['title'] ?? 'Untitled Event',
            'description': data['description'] ?? 'No description available',
            'date': data['date'] ?? Timestamp.now(),
            'location': data['location'] ?? 'Location not specified',
          };
        }).toList();

        _emergencyAlerts = alertsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'message': data['message'] ?? 'Emergency Alert',
            'timestamp': data['timestamp'] ?? Timestamp.now(),
            'isActive': data['isActive'] ?? true,
          };
        }).toList();

        _notificationCount = _emergencyAlerts.where((alert) => alert['isActive'] == true).length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _loadLatestAlert() async {
    setState(() => _isLoadingAlert = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('emergency_alerts')
          .where('isActive', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final alertData = snapshot.docs.first.data();
        setState(() {
          _latestAlert = EmergencyAlert.fromMap(alertData, snapshot.docs.first.id);
        });
      } else {
        setState(() {
          _latestAlert = null;
        });
      }
    } catch (e) {
      print('Error loading emergency alert: $e');
      setState(() {
        _latestAlert = null;
      });
    } finally {
      setState(() => _isLoadingAlert = false);
    }
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) => Transform.scale(
            scale: 0.5 + (0.5 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 400,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red[600],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Emergency Alerts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),

                // Content
                Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('emergency_alerts')
                        .where('isActive', isEqualTo: true)
                        .orderBy('timestamp', descending: true)
                        .snapshots()
                        .handleError((error) {
                          print('Firestore Error: $error');
                          if (error.toString().contains('indexes?create_composite=')) {
                            final indexUrl = error.toString().split('indexes?create_composite=')[1].split(' ')[0];
                            print('Create index at: https://console.firebase.google.com/v1/$indexUrl');
                          }
                          return Stream.error(error);
                        }),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.red[400],
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Failed to load alerts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  snapshot.error.toString().contains('indexes?create_composite=')
                                      ? 'Please create the required index in Firebase Console'
                                      : 'Please check your connection and try again',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading alerts...',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final alerts = snapshot.data?.docs ?? [];

                      if (alerts.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_off_outlined,
                                  color: Colors.grey[400],
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No active alerts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You\'ll be notified when there are new alerts',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shrinkWrap: true,
                        itemCount: alerts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final alert = alerts[index].data() as Map<String, dynamic>;
                          final timestamp = (alert['timestamp'] as Timestamp).toDate();
                          final isRecent = DateTime.now().difference(timestamp).inHours < 6;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isRecent ? Colors.red[50] : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isRecent ? Colors.red[100]! : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: isRecent ? Colors.red[600] : Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        alert['message'] ?? 'Emergency Alert',
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.4,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTimestamp(timestamp),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (isRecent) ...[
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.fiber_manual_record,
                                              size: 8,
                                              color: Colors.red[700],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'New',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _updateNotificationCount() async {
    try {
      final noticesSnapshot = await FirebaseFirestore.instance
          .collection('news_notices')
          .orderBy('timestamp', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _notificationCount = noticesSnapshot.docs.length;
        });
      }
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  void _showProfileDialog() {
    _showLoginDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/village_logo.png'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Village App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Connect with your community',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Village'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutVillage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhotoGalleryHome()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Government Schemes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GovernmentSchemes()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: const Text('Important Contacts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImportantContacts()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emergency, color: Colors.red),
              title: const Text('Emergency Services'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyServices()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Education'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MiddleSchoolScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Talent Corner'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TalentCorner()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(FontAwesomeIcons.code, size: 20),
              title: const Text('Developer'),
              subtitle: const Text('Ayush Singh (IT4B.in)'),
              trailing: IconButton(
                icon: const Icon(FontAwesomeIcons.instagram),
                onPressed: () async {
                  final Uri url = Uri.parse('https://instagram.com/ayushkssk');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'My Pratappur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showAlertDialog,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _showLoginDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_imageUrls.isNotEmpty) _buildImageSlider(),
                    _buildNotificationSlider(context),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Access',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickAccessItem(
                                icon: Icons.info,
                                label: 'About\nVillage',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AboutVillage(),
                                  ),
                                ),
                              ),
                              _buildQuickAccessItem(
                                icon: Icons.photo_library,
                                label: 'Photo\nGallery',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PhotoGalleryHome(),
                                  ),
                                ),
                              ),
                              _buildQuickAccessItem(
                                icon: Icons.policy,
                                label: 'Government\nSchemes',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GovernmentSchemes(),
                                  ),
                                ),
                              ),
                              _buildQuickAccessItem(
                                icon: Icons.contact_phone,
                                label: 'Important\nContacts',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ImportantContacts(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickAccessItem(
                                icon: Icons.emergency,
                                label: 'Emergency\nServices',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EmergencyServices(),
                                  ),
                                ),
                                color: Colors.red,
                              ),
                              _buildQuickAccessItem(
                                icon: Icons.phone_in_talk,
                                label: 'Helpline\nNumbers',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ImportantHelplines(),
                                  ),
                                ),
                                color: Colors.indigo,
                              ),
                              _buildQuickAccessItem(
                                icon: Icons.school,
                                label: 'Education',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MiddleSchoolScreen(),
                                  ),
                                ),
                              ),
                              _buildQuickAccessItem(
                                icon: Icons.star,
                                label: 'Talent\nCorner',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TalentCorner(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Updates',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRecentUpdateCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: widget.showBottomBar ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _handleBottomNavigation,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle),
            label: 'Reels',
          ),
        ],
      ) : null,
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.green,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 48) / 4; // 48 is total horizontal padding (16 * 3)
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: itemWidth,
        height: itemWidth,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: itemWidth * 0.3, // Proportional icon size
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: itemWidth * 0.11, // Proportional text size
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Container(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _newsController,
            itemCount: _imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentNewsIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _imageUrls.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentNewsIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdateCard() {
    if (_newsUpdates.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No recent updates'),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 400, // Fixed height for the PageView
            child: PageView.builder(
              controller: _updateController,
              onPageChanged: (index) {
                setState(() {
                  _selectedUpdateIndex = index;
                });
              },
              itemCount: _newsUpdates.length,
              itemBuilder: (context, index) {
                final update = _newsUpdates[index];
                final imageUrl = update['imageUrl'] as String;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (imageUrl.isNotEmpty)
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: imageUrl.startsWith('assets/')
                            ? Image.asset(
                                imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                        ),
                      ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              update['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                update['content'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Text(
                              _getTimeAgo(update['timestamp']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_newsUpdates.length > 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _newsUpdates.length; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _selectedUpdateIndex
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildNotificationSlider(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'icon': '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 15.5C11.7167 15.5 11.4793 15.404 11.288 15.212C11.096 15.0207 11 14.7833 11 14.5V9.5C11 9.21667 11.096 8.979 11.288 8.787C11.4793 8.59567 11.7167 8.5 12 8.5C12.2833 8.5 12.521 8.59567 12.713 8.787C12.9043 8.979 13 9.21667 13 9.5V14.5C13 14.7833 12.9043 15.0207 12.713 15.212C12.521 15.404 12.2833 15.5 12 15.5ZM12 18.5C11.7167 18.5 11.4793 18.404 11.288 18.212C11.096 18.0207 11 17.7833 11 17.5C11 17.2167 11.096 16.979 11.288 16.787C11.4793 16.5957 11.7167 16.5 12 16.5C12.2833 16.5 12.521 16.5957 12.713 16.787C12.9043 16.979 13 17.2167 13 17.5C13 17.7833 12.9043 18.0207 12.713 18.212C12.521 18.404 12.2833 18.5 12 18.5ZM12 22.5C10.6833 22.5 9.446 22.2373 8.288 21.712C7.12933 21.1873 6.125 20.475 5.275 19.575C4.425 18.675 3.77067 17.6457 3.312 16.487C2.854 15.329 2.625 14.0917 2.625 12.775C2.625 11.4583 2.854 10.221 3.312 9.063C3.77067 7.90433 4.425 6.875 5.275 5.975C6.125 5.075 7.12933 4.36267 8.288 3.838C9.446 3.31267 10.6833 3.05 12 3.05C13.3167 3.05 14.5543 3.31267 15.713 3.838C16.871 4.36267 17.875 5.075 18.725 5.975C19.575 6.875 20.229 7.90433 20.687 9.063C21.1457 10.221 21.375 11.4583 21.375 12.775C21.375 14.0917 21.1457 15.329 20.687 16.487C20.229 17.6457 19.575 18.675 18.725 19.575C17.875 20.475 16.871 21.1873 15.713 21.712C14.5543 22.2373 13.3167 22.5 12 22.5ZM12 20.5C14.2333 20.5 16.125 19.725 17.675 18.175C19.225 16.625 20 14.7333 20 12.5C20 10.2667 19.225 8.375 17.675 6.825C16.125 5.275 14.2333 4.5 12 4.5C9.76667 4.5 7.875 5.275 6.325 6.825C4.775 8.375 4 10.2667 4 12.5C4 14.7333 4.775 16.625 6.325 18.175C7.875 19.725 9.76667 20.5 12 20.5ZM12 22.5C10.6833 22.5 9.446 22.2373 8.288 21.712C7.12933 21.1873 6.125 20.475 5.275 19.575C4.425 18.675 3.77067 17.6457 3.312 16.487C2.854 15.329 2.625 14.0917 2.625 12.775C2.625 11.4583 2.854 10.221 3.312 9.063C3.77067 7.90433 4.425 6.875 5.275 5.975C6.125 5.075 7.12933 4.36267 8.288 3.838C9.446 3.31267 10.6833 3.05 12 3.05C13.3167 3.05 14.5543 3.31267 15.713 3.838C16.871 4.36267 17.875 5.075 18.725 5.975C19.575 6.875 20.229 7.90433 20.687 9.063C21.1457 10.221 21.375 11.4583 21.375 12.775C21.375 14.0917 21.1457 15.329 20.687 16.487C20.229 17.6457 19.575 18.675 18.725 19.575C17.875 20.475 16.871 21.1873 15.713 21.712C14.5543 22.2373 13.3167 22.5 12 22.5Z" fill="#2196F3"/>
        </svg>''',
        'title': 'हर घर नल का जल',
        'description': 'अपने जिले के नियंत्रण कक्ष और अभियंता से संपर्क करें',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 80,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final notification = notifications[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HarGharNalJal()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SvgPicture.string(
                          notification['icon'],
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                notification['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: notifications.length,
        autoplay: true,
        autoplayDelay: 5000,
        duration: 800,
        scale: 0.9,
        viewportFraction: 0.93,
      ),
    );
  }
}

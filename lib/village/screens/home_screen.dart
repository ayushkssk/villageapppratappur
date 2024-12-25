import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:villageapp/village/auth/providers/auth_provider.dart';
import 'package:villageapp/village/auth/screens/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import './admin/admin_panel.dart';
import './about_village.dart';
import './emergency_services.dart';
import './government_schemes.dart';
import './grievance_portal.dart';
import './important_contacts.dart';
import './notifications.dart';
import './photo_gallery_home.dart';
import './photo_gallery_screen.dart';
import './talent_corner.dart';
import './contact_form.dart';
import './middle_school/middle_school_screen.dart';
import '../services/firestore_service.dart';
import '../models/news_update.dart';
import '../models/event.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'chat_screen.dart';
import 'events_screen.dart';
import 'reels_screen.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import './main_screen.dart';

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

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _screens[index]),
      );
    }
  }

  void _onItemTappedOld(int index) {
    if (!widget.showBottomBar) return;
    
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReelsScreen()),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _startImageSlideTimer();
    _startUpdateAutoSlide();
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _loadData();
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

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text(
        'Village App',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        // Admin Button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPanel(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Notification Bell
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Emergency Alerts'),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _emergencyAlerts.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No active emergency alerts'),
                                )
                              ]
                            : _emergencyAlerts.map((alert) {
                                return Card(
                                  color: Colors.red.shade50,
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                    ),
                                    title: Text(alert['message']),
                                    subtitle: Text(
                                      'Posted: ${(alert['timestamp'] as Timestamp).toDate().toString().split('.')[0]}',
                                    ),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (_notificationCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$_notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Logout Button
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          tooltip: 'Logout',
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                      
                      try {
                        await context.read<AuthProvider>().signOut();
                        if (!mounted) return;
                        Navigator.pop(context); // Close loading dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        Navigator.pop(context); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/village_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Pratappur',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline, size: 28),
                      title: const Text(
                        'About Village',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutVillage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined, size: 28),
                      title: const Text(
                        'Photo Gallery',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhotoGalleryHome(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.emergency_outlined, size: 28),
                      title: const Text(
                        'Emergency Services',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmergencyServices(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.contact_phone_outlined, size: 28),
                      title: const Text(
                        'Important Contacts',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImportantContacts(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.policy_outlined, size: 28),
                      title: const Text(
                        'Government Schemes',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GovernmentSchemes(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.report_problem_outlined, size: 28),
                      title: const Text(
                        'Grievance Portal',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GrievancePortal(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star_outline, size: 28),
                      title: const Text(
                        'Talent Corner',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TalentCorner(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.school_outlined, size: 28),
                      title: const Text(
                        'Education',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MiddleSchoolScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 16),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.7),
                    Theme.of(context).primaryColor.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 200));
                    // Try to open in Instagram app first
                    final Uri instagramUrl = Uri.parse('instagram://user?username=ayushkssk');
                    final Uri webUrl = Uri.parse('https://www.instagram.com/ayushkssk');
                    
                    try {
                      final bool canOpenApp = await canLaunchUrl(instagramUrl);
                      if (canOpenApp) {
                        await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                      }
                    } catch (e) {
                      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'DEVELOPER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Crafted with ❤️ by ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              'Ayush Singh ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'IT4B.in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
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
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _buildBody(),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_collection),
                  label: 'Reels',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSlider(),
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
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
                      icon: Icons.report_problem,
                      label: 'Grievance\nPortal',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GrievancePortal(),
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
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.green,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color,
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
}

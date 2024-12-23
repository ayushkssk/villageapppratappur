import 'package:flutter/material.dart';
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
import './chat/coming_soon_screen.dart';
import '../widgets/base_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedIndex = 0;
  final List<String> _imageList = [
    'assets/images/village1.png',
    'assets/images/village2.png',
    'assets/images/village3.png',
    'assets/images/village4.png',
    'assets/images/village5.png',
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startAutoPlay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (_currentPage < _imageList.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
        _startAutoPlay();
      }
    });
  }

  Widget _buildQuickAccessCard(String title, IconData icon, VoidCallback onPressed, {bool isEmergency = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isEmergency ? Colors.red.shade50 : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmergency ? Colors.red.shade200 : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isEmergency ? Colors.red : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isEmergency ? Colors.red : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateCard(BuildContext context, String title, String description, String imagePath) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index != 0) { // Not home
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            switch (index) {
              case 1:
                return const AboutVillage();
              case 2:
                return const ComingSoonScreen();
              case 3:
                return const AboutVillage(); // Replace with Festival screen when created
              default:
                return const HomeScreen();
            }
          },
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0; // Reset to home when returning
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Village App'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
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
                      child: const Text(
                        'Pratappur',
                        style: TextStyle(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            icon: const Icon(Icons.emergency, color: Colors.white),
            label: const Text(
              'Emergency',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmergencyServices()),
              );
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Slider
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page % _imageList.length;
                          });
                        },
                        itemCount: _imageList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                _imageList[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Quick Access Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Access',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                _buildQuickAccessCard(
                                  'Photo\nGallery',
                                  Icons.photo_library,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PhotoGalleryHome(),
                                      ),
                                    );
                                  },
                                ),
                                _buildQuickAccessCard(
                                  'Government\nSchemes',
                                  Icons.policy,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const GovernmentSchemes(),
                                      ),
                                    );
                                  },
                                ),
                                _buildQuickAccessCard(
                                  'Important\nContacts',
                                  Icons.contact_phone,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ImportantContacts(),
                                      ),
                                    );
                                  },
                                ),
                                _buildQuickAccessCard(
                                  'Add\nContact',
                                  Icons.person_add,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ContactFormScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Recent Updates
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Updates',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildUpdateCard(
                            context,
                            'New Road Construction Completed',
                            'The road construction from main market to village has been completed.',
                            'assets/images/village.png',
                          ),
                          _buildUpdateCard(
                            context,
                            'Cleanliness Drive',
                            'A cleanliness drive was organized in the village.',
                            'assets/images/village_logo.png',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

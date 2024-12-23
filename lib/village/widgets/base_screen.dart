import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/about_village.dart';
import '../screens/chat/coming_soon_screen.dart';
import '../screens/feed/reels_screen.dart';

class BaseScreen extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const BaseScreen({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  void _onItemTapped(int index) {
    if (index != widget.currentIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            switch (index) {
              case 0:
                return const HomeScreen();
              case 1:
                return const AboutVillage();
              case 2:
                return const ComingSoonScreen();
              case 3:
                return const ReelsScreen();
              default:
                return const HomeScreen();
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_outlined),
              activeIcon: Icon(Icons.account_balance),
              label: 'Village History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feed_outlined),
              activeIcon: Icon(Icons.feed),
              label: 'Feed/Status',
            ),
          ],
        ),
      ),
    );
  }
}

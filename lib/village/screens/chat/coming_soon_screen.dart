import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Village Chat'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 100,
                  color: Colors.blue.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'यहाँ आप अपने गाँव के लोगों से बातें कर सकते हैं',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Here you can chat with people from your village',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

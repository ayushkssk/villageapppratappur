import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'about_village.dart';
import 'chat_screen.dart';
import 'events_screen.dart';
import 'home_screen.dart';
import '../widgets/common_navbar.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;
  int _selectedIndex = 4;
  final List<String> _videoUrls = [
    'https://ia800106.us.archive.org/2/items/milleschool_v0/VIDEO-2024-12-23-13-16-31.mp4',
    'https://ia800105.us.archive.org/35/items/temple_01/4ab38db2-4600-4b82-a13d-3f021db880cf.MP4',  
    'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-in-nature-39764-large.mp4',
  ];
  
  final List<VideoPlayerController> _controllers = [];
  final List<ChewieController?> _chewieControllers = [];
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AboutVillage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EventsScreen()),
        );
        break;
      case 4:
        // Already on Reels screen
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    for (var videoUrl in _videoUrls) {
      final controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();
      
      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: _controllers.isEmpty,
        looping: true,
        showControls: false,
        aspectRatio: controller.value.aspectRatio,
      );
      
      _controllers.add(controller);
      _chewieControllers.add(chewieController);
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var controller in _chewieControllers) {
      controller?.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      if (_currentIndex < _controllers.length) {
        _controllers[_currentIndex].pause();
      }
      if (index < _controllers.length) {
        _controllers[index].play();
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reels'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _chewieControllers.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              itemCount: _videoUrls.length,
              itemBuilder: (context, index) {
                if (_chewieControllers[index] == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Chewie(
                      controller: _chewieControllers[index]!,
                    ),
                    Positioned(
                      right: 16,
                      bottom: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.white, size: 30),
                            onPressed: () {},
                          ),
                          const Text('0', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 20),
                          IconButton(
                            icon: const Icon(Icons.comment_outlined, color: Colors.white, size: 30),
                            onPressed: () {},
                          ),
                          const Text('0', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 20),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 30),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: const CommonNavBar(currentIndex: 3),
    );
  }
}

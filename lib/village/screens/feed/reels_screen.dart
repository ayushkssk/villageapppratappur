import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../widgets/base_screen.dart';
import '../../screens/home_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;
  final List<String> _videoUrls = [
    'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-in-nature-39764-large.mp4',
    // Add more video URLs here
  ];
  
  final List<VideoPlayerController> _controllers = [];
  final List<ChewieController?> _chewieControllers = [];
  int _currentIndex = 0;

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
      // Pause the previous video
      if (_currentIndex < _controllers.length) {
        _controllers[_currentIndex].pause();
      }
      // Play the current video
      if (index < _controllers.length) {
        _controllers[index].play();
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          title: const Text(
            'Reels',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
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
                      // Add overlay buttons, text, etc. here
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
      ),
    );
  }
}

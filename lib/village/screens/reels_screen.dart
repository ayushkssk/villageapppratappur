import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:like_button/like_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/common_navbar.dart';
import '../services/reel_service.dart';
import '../models/reel_model.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  final ReelService _reelService = ReelService();
  List<ReelModel> _reels = [];
  List<VideoPlayerController> _videoControllers = [];
  List<ValueNotifier<double>> _progressValues = [];
  Timer? _progressTimer;
  bool _showPlayButton = true;
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadReels();
  }

  Future<void> _loadReels() async {
    try {
      _reelService.getReels().listen((reels) {
        setState(() {
          _reels = reels;
          _isLoading = false;
        });
        _initializeControllers();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reels: $e')),
        );
      }
    }
  }

  Future<void> _initializeControllers() async {
    // Dispose old controllers
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _videoControllers.clear();
    _progressValues.clear();

    // Initialize new controllers
    for (var reel in _reels) {
      final controller = VideoPlayerController.network(reel.videoUrl);
      _videoControllers.add(controller);
      _progressValues.add(ValueNotifier<double>(0.0));

      try {
        await controller.initialize();
        if (_videoControllers.indexOf(controller) == _currentIndex) {
          controller.play();
          _startProgressTimer();
        }
        setState(() {});
      } catch (e) {
        print('Error initializing video controller: $e');
      }
    }
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted && !_isLoading) {
        _checkVideoProgress();
      }
    });
  }

  void _checkVideoProgress() {
    if (!mounted || _isLoading) return;
    
    final controller = _videoControllers[_currentIndex];
    if (controller.value.isInitialized && controller.value.isPlaying) {
      final duration = controller.value.duration;
      final position = controller.value.position;
      if (duration.inMilliseconds > 0) {
        final progress = position.inMilliseconds / duration.inMilliseconds;
        if (progress > 0.98) {
          _playNextVideo();
        }
      }
    }
  }

  void _playNextVideo() {
    if (!mounted || _isLoading) return;
    
    try {
      final nextIndex = (_currentIndex + 1) % _reels.length;
      
      // Animate to next page
      _currentIndex = nextIndex;
      setState(() {
        _showPlayButton = false; // Hide play button on next video
      });
      
      // Stop current video
      if (_currentIndex < _videoControllers.length) {
        _videoControllers[_currentIndex].pause();
        _videoControllers[_currentIndex].seekTo(Duration.zero);
      }
      
      // Play next video
      if (nextIndex < _videoControllers.length) {
        _videoControllers[nextIndex].play();
      }
    } catch (e) {
      print('Error in _playNextVideo: $e');
    }
  }

  Widget _buildReelItem(ReelModel reel) {
    final index = _reels.indexOf(reel);
    return Stack(
      children: [
        // Full screen video container
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: _videoControllers[index].value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoControllers[index].value.size.width,
                      height: _videoControllers[index].value.size.height,
                      child: VideoPlayer(_videoControllers[index]),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        // Play/Pause Indicator with better visibility control
        if (_showPlayButton)
          AnimatedOpacity(
            opacity: _videoControllers[index].value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    _videoControllers[index].value.isPlaying 
                        ? Icons.pause 
                        : Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        // Video Description and Progress at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Description with gradient background
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  top: 32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  reel.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Progress bar
              ValueListenableBuilder<double>(
                valueListenable: _progressValues[index] ?? ValueNotifier<double>(0.0),
                builder: (context, progress, child) {
                  return Stack(
                    children: [
                      // Background track
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.3),
                              Colors.grey.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      // Progress indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        height: 4,
                        width: MediaQuery.of(context).size.width * progress,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.purple,
                              Colors.pink,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.5),
                              blurRadius: 6.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoControllers[_currentIndex].value.isPlaying) {
        _videoControllers[_currentIndex].pause();
        _showPlayButton = true;
      } else {
        _videoControllers[_currentIndex].play();
        _showPlayButton = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reels',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReelScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            itemBuilder: (context, index) {
              return _buildReelItem(_reels[index]);
            },
          ),
      bottomNavigationBar: const CommonNavBar(currentIndex: 3),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_videoControllers.isNotEmpty) {
        _videoControllers[_currentIndex].pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (mounted && _videoControllers.isNotEmpty) {
        _videoControllers[_currentIndex].play();
      }
    }
  }

  @override
  void deactivate() {
    // Pause video when navigating away
    if (_videoControllers.isNotEmpty) {
      _videoControllers[_currentIndex].pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    try {
      _progressTimer?.cancel();
      _progressValues.forEach((_, notifier) => notifier.dispose());
      _progressValues.clear();
      
      WidgetsBinding.instance.removeObserver(this);
      for (var controller in _videoControllers) {
        controller.dispose();
      }
    } catch (e) {
      print('Error in dispose: $e');
    }
    super.dispose();
  }
}

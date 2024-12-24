import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:like_button/like_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/common_navbar.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  late List<VideoPlayerController> _videoControllers;
  final Map<int, Completer<void>> _initializedVideos = {};
  int _currentPage = 0;
  bool _isMuted = false;
  bool _isAppInBackground = false;
  bool _showGuidance = true;
  final Map<int, int> _retryCount = {};
  final int _maxRetries = 3;
  Map<int, ValueNotifier<double>> _progressValues = {};
  Timer? _progressTimer;
  bool _showPlayButton = false;

  // Cache for initialized videos
  // Video error retry count
  // Track video progress for all videos

  Future<void> _initializeVideo(int index) async {
    if (_initializedVideos[index] == null) {
      _initializedVideos[index] = Completer<void>();
      try {
        await _videoControllers[index].initialize();
        _videoControllers[index].setLooping(true);
        _videoControllers[index].setVolume(_isMuted ? 0 : 1);
        _initializedVideos[index]?.complete();
        _retryCount[index] = 0; // Reset retry count on success
      } catch (e) {
        print('Error initializing video $index: $e');
        _initializedVideos[index]?.completeError(e);
        
        // Implement retry logic
        _retryCount[index] = (_retryCount[index] ?? 0) + 1;
        if ((_retryCount[index] ?? 0) < _maxRetries) {
          Future.delayed(Duration(seconds: _retryCount[index] ?? 1), () {
            if (mounted && !(_initializedVideos[index]?.isCompleted ?? true)) {
              print('Retrying video $index initialization. Attempt: ${_retryCount[index]}');
              _initializeVideo(index);
            }
          });
        } else {
          print('Max retries reached for video $index');
          // Show error UI
          setState(() {});
        }
      }
    }
    return _initializedVideos[index]?.future;
  }

  void _preloadAdjacentVideos(int currentIndex) {
    // Preload next video
    if (currentIndex < _reels.length - 1) {
      _initializeVideo(currentIndex + 1);
    }
    // Preload previous video
    if (currentIndex > 0) {
      _initializeVideo(currentIndex - 1);
    }
  }

  // Demo reels data
  final List<Map<String, dynamic>> _reels = [
    {
      'videoUrl': 'https://ia800106.us.archive.org/2/items/milleschool_v0/VIDEO-2024-12-23-13-16-31.mp4',
      'description': 'School activities in our village 📚',
    },
    {
      'videoUrl': 'https://ia800105.us.archive.org/35/items/temple_01/4ab38db2-4600-4b82-a13d-3f021db880cf.MP4',
      'description': 'Beautiful temple in our village 🙏',
    },
    {
      'videoUrl': 'https://ia600106.us.archive.org/2/items/milleschool_v0/VIDEO-2024-12-23-13-16-31.mp4',
      'description': 'Daily life in our village 🌅',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize controllers and progress trackers
    _videoControllers = List.generate(
      _reels.length,
      (index) => VideoPlayerController.network(
        _reels[index]['videoUrl'],
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      )..addListener(() {
        // Update progress for this video
        if (_progressValues[index] != null) {
          final duration = _videoControllers[index].value.duration;
          final position = _videoControllers[index].value.position;
          if (duration.inMilliseconds > 0) {
            final progress = position.inMilliseconds / duration.inMilliseconds;
            _progressValues[index]?.value = progress.clamp(0.0, 1.0);
            
            // Check if video is near end (98% complete)
            if (progress > 0.98 && mounted && _currentPage == index) {
              _playNextVideo();
            }
          }
        }
      }),
    );

    // Initialize progress trackers
    for (int i = 0; i < _reels.length; i++) {
      _progressValues[i] = ValueNotifier<double>(0.0);
    }

    // Initialize first video and preload adjacent
    _initializeVideo(0).then((_) {
      if (mounted && !_isAppInBackground) {
        _videoControllers[0].play();
        _preloadAdjacentVideos(0);
      }
    });

    // Start progress checking timer
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted && !_isAppInBackground) {
        _checkVideoProgress();
      }
    });

    // Hide guidance after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showGuidance = false);
      }
    });
  }

  void _checkVideoProgress() {
    if (!mounted || _isAppInBackground) return;
    
    final controller = _videoControllers[_currentPage];
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
    if (!mounted || _isAppInBackground) return;
    
    try {
      final nextIndex = (_currentPage + 1) % _reels.length;
      
      // Animate to next page
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ).then((_) {
        if (mounted) {
          setState(() {
            _showPlayButton = false; // Hide play button on next video
          });
          
          // Stop current video
          if (_currentPage < _videoControllers.length) {
            _videoControllers[_currentPage].pause();
            _videoControllers[_currentPage].seekTo(Duration.zero);
          }
          
          // Play next video
          if (nextIndex < _videoControllers.length) {
            _initializeVideo(nextIndex).then((_) {
              if (mounted && !_isAppInBackground) {
                _videoControllers[nextIndex].play();
              }
            });
          }
        }
      });
    } catch (e) {
      print('Error in _playNextVideo: $e');
    }
  }

  void _onPageChanged(int page) {
    if (!mounted) return;
    
    final oldPage = _currentPage;
    setState(() {
      _currentPage = page;
      _showPlayButton = false; // Hide play button on page change
    });

    try {
      // Stop old video
      if (_videoControllers.isNotEmpty && oldPage < _videoControllers.length) {
        _videoControllers[oldPage].pause();
        _videoControllers[oldPage].seekTo(Duration.zero);
      }
      
      // Play new video
      if (page < _videoControllers.length) {
        _initializeVideo(page).then((_) {
          if (mounted && !_isAppInBackground && _currentPage == page) {
            _videoControllers[page].play();
          }
        });

        // Preload adjacent videos
        _preloadAdjacentVideos(page);
        
        // If we reached the end, prepare to loop
        if (page == _reels.length - 1) {
          _initializeVideo(0); // Preload first video
        }
      }
    } catch (e) {
      print('Error in _onPageChanged: $e');
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      for (var controller in _videoControllers) {
        controller.setVolume(_isMuted ? 0 : 1);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoControllers[_currentPage].value.isPlaying) {
        _videoControllers[_currentPage].pause();
        _showPlayButton = true;
      } else {
        _videoControllers[_currentPage].play();
        _showPlayButton = false;
      }
    });
  }

  Widget _buildReelItem(Map<String, dynamic> reel) {
    final index = _reels.indexOf(reel);
    return Stack(
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            color: Colors.black,
            child: _videoControllers[index].value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoControllers[index].value.aspectRatio,
                    child: VideoPlayer(_videoControllers[index]),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        // Static Guidance Text at top
        Positioned(
          top: 60, // Below app bar
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tap: Mute • Double Tap: Play/Pause',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
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
        // Video Description at bottom with gradient
        Positioned(
          bottom: 4, // Moved up to make space for progress bar
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 40,
              top: 40,
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
              reel['description'],
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
        ),
        // Enhanced Progress Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<double>(
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
                  // Time indicator
                  if (_videoControllers[index].value.isInitialized)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(_videoControllers[index].value.duration - 
                                          _videoControllers[index].value.position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Format duration to mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.purple, Colors.pink, Colors.orange],
              ).createShader(bounds),
              child: const Text(
                'Village',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text(
              'Reels',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.black87,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Create New Reel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.video_library, color: Colors.purple),
                        ),
                        title: const Text(
                          'Upload Video',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Share a video from your gallery',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Upload feature coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.camera, color: Colors.pink),
                        ),
                        title: const Text(
                          'Record Video',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Create a new video reel',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recording feature coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
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
      _isAppInBackground = true;
      if (_videoControllers.isNotEmpty) {
        _videoControllers[_currentPage].pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      _isAppInBackground = false;
      if (mounted && _videoControllers.isNotEmpty) {
        _videoControllers[_currentPage].play();
      }
    }
  }

  @override
  void deactivate() {
    // Pause video when navigating away
    if (_videoControllers.isNotEmpty) {
      _videoControllers[_currentPage].pause();
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
      _initializedVideos.clear();
      _pageController.dispose();
    } catch (e) {
      print('Error in dispose: $e');
    }
    super.dispose();
  }
}

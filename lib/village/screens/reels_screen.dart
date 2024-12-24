import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:like_button/like_button.dart';
import '../widgets/common_navbar.dart';
import '../models/reel_model.dart';
import '../services/reel_service.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

/// The state for the ReelsScreen widget.
/// Handles video playback, user interactions, and memory management.
class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  /// Service to handle reel-related operations
  final ReelService _reelService = ReelService();
  
  /// Controller for handling page swipes
  final PageController _pageController = PageController();
  
  /// List of all reels
  List<ReelModel> _reels = [];
  
  /// Map of video controllers for efficient memory management
  Map<int, VideoPlayerController> _controllers = {};
  
  /// Map of progress values for each video
  Map<int, ValueNotifier<double>> _progressValues = {};
  
  /// Map to track initialization status of videos
  Map<int, bool> _isInitialized = {};
  
  /// Index of currently playing video
  int _currentIndex = 0;
  
  /// Flag to track if videos are muted
  bool _isMuted = false;
  
  /// Loading state flag
  bool _isLoading = true;
  
  /// Flag to track if app is in background
  bool _isAppInBackground = false;
  
  /// Flag to show/hide guidance text
  bool _showGuidance = true;
  
  /// Timer for auto-hiding guidance text
  Timer? _guidanceTimer;
  
  /// Map to track retry attempts for failed video loads
  final Map<int, int> _retryCount = {};
  
  /// Maximum number of retry attempts
  final int _maxRetries = 3;
  
  /// Timer for tracking video progress
  Timer? _progressTimer;
  
  /// Flag to show/hide play/pause button
  bool _showPlayButton = false;
  
  /// Timer for auto-hiding play/pause button
  Timer? _playButtonTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    _loadReels();
    
    // Auto-hide guidance after 3 seconds
    _guidanceTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showGuidance = false);
      }
    });
  }

  /// Loads reels from the ReelService and initializes the first three videos.
  Future<void> _loadReels() async {
    try {
      _reelService.getReels().listen((reels) {
        if (mounted) {
          setState(() {
            _reels = reels;
            _isLoading = false;
          });
          if (_reels.isNotEmpty) {
            // Initialize first three videos immediately
            for (var i = 0; i < 3 && i < _reels.length; i++) {
              _initializeController(i);
            }
          }
        }
      });
    } catch (e) {
      print('Error loading reels: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Initializes a video controller for the given index.
  /// Handles video initialization, playback, and progress tracking.
  Future<void> _initializeController(int index) async {
    if (index < 0 || index >= _reels.length) return;
    if (_controllers[index]?.value.isInitialized ?? false) return;
    
    try {
      final controller = VideoPlayerController.network(
        _reels[index].videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      
      _controllers[index] = controller;
      _progressValues[index] = ValueNotifier(0.0);
      
      await controller.initialize();
      
      if (!mounted) {
        await _cleanupController(index);
        return;
      }
      
      controller.addListener(() {
        if (!mounted) return;
        if (controller.value.isInitialized) {
          final duration = controller.value.duration.inMilliseconds;
          final position = controller.value.position.inMilliseconds;
          
          if (duration > 0) {
            _progressValues[index]?.value = position / duration;
            
            if (position >= duration && index == _currentIndex) {
              _playNextVideo();
            }
          }
        }
      });
      
      if (index == _currentIndex && mounted) {
        await controller.play();
      }
      
    } catch (e) {
      print('Error initializing video $index: $e');
      await _cleanupController(index);
    }
  }

  /// Cleans up a video controller and its associated resources.
  Future<void> _cleanupController(int index) async {
    final controller = _controllers[index];
    if (controller != null) {
      await controller.pause();
      await controller.dispose();
      _controllers.remove(index);
      _progressValues[index]?.dispose();
      _progressValues.remove(index);
      _isInitialized[index] = false;
    }
  }

  /// Cleans up all video controllers and their associated resources.
  Future<void> _cleanupAllControllers() async {
    for (final controller in _controllers.values) {
      await controller.pause();
      await controller.dispose();
    }
    for (final notifier in _progressValues.values) {
      notifier.dispose();
    }
    _controllers.clear();
    _progressValues.clear();
    _isInitialized.clear();
  }

  /// Handles page changes by pausing the old video, updating views, and playing the new video.
  Future<void> _onPageChanged(int index) async {
    if (!mounted || index < 0 || index >= _reels.length) return;
    
    final oldIndex = _currentIndex;
    _currentIndex = index;
    
    setState(() {
      _showPlayButton = false;
    });

    try {
      // Pause old video
      _controllers[oldIndex]?.pause();
      
      // Update views
      await _reelService.updateViews(_reels[index].id);
      
      // Initialize current video if needed
      if (_controllers[index] == null) {
        await _initializeController(index);
      }
      
      // Play current video
      final controller = _controllers[index];
      if (controller?.value.isInitialized ?? false) {
        await controller?.seekTo(Duration.zero);
        controller?.play();
      }
      
      // Pre-load adjacent videos
      if (index > 0) {
        _initializeController(index - 1);
      }
      if (index < _reels.length - 1) {
        _initializeController(index + 1);
      }
      
      // Cleanup far videos
      final keysToRemove = _controllers.keys
          .where((key) => (key - index).abs() > 1)
          .toList();
      
      for (final key in keysToRemove) {
        await _cleanupController(key);
      }
      
    } catch (e) {
      print('Error in page change: $e');
    }
  }

  /// Plays the next video in the list.
  void _playNextVideo() {
    if (!mounted) return;
    if (_currentIndex < _reels.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If it's the last video, loop back to first
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Toggles play/pause state of the current video.
  void _togglePlayPause() {
    setState(() {
      if (_controllers[_currentIndex]?.value.isPlaying ?? false) {
        _controllers[_currentIndex]?.pause();
        _showPlayButton = true;
      } else {
        _controllers[_currentIndex]?.play();
        _showPlayButton = true;
        // Hide play button after 0.5 seconds
        _playButtonTimer?.cancel();
        _playButtonTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _showPlayButton = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cleanupAllControllers();
    WidgetsBinding.instance.removeObserver(this);
    _guidanceTimer?.cancel();
    _playButtonTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controllers[_currentIndex]?.pause();
      _isAppInBackground = true;
    } else if (state == AppLifecycleState.resumed && _isAppInBackground) {
      _isAppInBackground = false;
      if (mounted && (ModalRoute.of(context)?.isCurrent == true)) {
        _initializeController(_currentIndex);
      }
    }
  }

  @override
  void deactivate() {
    _controllers[_currentIndex]?.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _controllers[_currentIndex]?.pause();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF405DE6),
                Color(0xFF5851DB),
                Color(0xFF833AB4),
                Color(0xFFC13584),
                Color(0xFFE1306C),
                Color(0xFFFD1D1D),
                Color(0xFFF56040),
                Color(0xFFF77737),
                Color(0xFFFCAF45),
                Color(0xFFFFDC80),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Pratappur Feed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              itemCount: _reels.length,
              itemBuilder: (context, index) {
                final reel = _reels[index];
                final controller = _controllers[index];
                final progressValue = _progressValues[index];

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: _togglePlayPause,
                      onDoubleTap: () async {
                        try {
                          await _reelService.updateLikes(reel.id, true);
                        } catch (e) {
                          print('Error updating likes: $e');
                        }
                      },
                      child: Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: controller?.value.isInitialized ?? false
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: controller!.value.size.width,
                                      height: controller.value.size.height,
                                      child: VideoPlayer(controller),
                                    ),
                                  ),
                                  // Gradient overlay for better text visibility
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.center,
                                        colors: [
                                          Colors.black.withOpacity(0.6),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_showPlayButton)
                                    Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Icon(
                                          _controllers[_currentIndex]?.value.isPlaying ?? false
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 50,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    // Description and progress bar at bottom with gradient background
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
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
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: MediaQuery.of(context).padding.bottom + 70,
                          top: 50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reel.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (progressValue != null)
                              Container(
                                height: 3,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(1.5),
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: progressValue,
                                    builder: (context, value, child) {
                                      return LinearProgressIndicator(
                                        value: value,
                                        backgroundColor: Colors.grey.withOpacity(0.2),
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFE1306C), // Instagram pink color
                                        ),
                                        minHeight: 3,
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 100,
                      child: Column(
                        children: [
                          LikeButton(
                            size: 40,
                            likeCount: reel.likes,
                            countBuilder: (count, isLiked, text) {
                              return Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            },
                            onTap: (isLiked) async {
                              await _reelService.updateLikes(reel.id, !isLiked);
                              return !isLiked;
                            },
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              const Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${reel.views}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_showGuidance)
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => setState(() => _showGuidance = false),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Tap to play/pause • Swipe up for next reel',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: const CommonNavBar(currentIndex: 3),
      ),
    );
  }
}

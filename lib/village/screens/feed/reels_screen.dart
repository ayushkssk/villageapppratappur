import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<ReelItem> _reels = [
    ReelItem(
      videoUrl: 'https://example.com/reel1.mp4', // Replace with actual video URLs
      userAvatar: 'assets/images/village_logo.png',
      username: 'village_user1',
      description: 'Beautiful sunset at our village temple 🌅 #VillageLife',
      likes: 245,
      comments: 23,
    ),
    // Add more reels here
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            onPressed: () {
              // TODO: Implement reel creation
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemCount: _reels.length,
        itemBuilder: (context, index) {
          return ReelView(reel: _reels[index]);
        },
      ),
    );
  }
}

class ReelView extends StatefulWidget {
  final ReelItem reel;

  const ReelView({
    super.key,
    required this.reel,
  });

  @override
  State<ReelView> createState() => _ReelViewState();
}

class _ReelViewState extends State<ReelView> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.reel.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller.value.isInitialized)
            VideoPlayer(_controller)
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          // Video Controls Overlay
          if (!_isPlaying)
            const Center(
              child: Icon(
                Icons.play_arrow,
                size: 80,
                color: Colors.white,
              ),
            ),
          // User Info and Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(widget.reel.userAvatar),
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.reel.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    widget.reel.description,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Action Buttons
          Positioned(
            right: 8,
            bottom: 100,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                    size: 32,
                  ),
                  onPressed: _toggleLike,
                ),
                Text(
                  '${widget.reel.likes}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(
                    Icons.comment_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    // TODO: Show comments bottom sheet
                  },
                ),
                Text(
                  '${widget.reel.comments}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReelItem {
  final String videoUrl;
  final String userAvatar;
  final String username;
  final String description;
  final int likes;
  final int comments;

  ReelItem({
    required this.videoUrl,
    required this.userAvatar,
    required this.username,
    required this.description,
    required this.likes,
    required this.comments,
  });
}

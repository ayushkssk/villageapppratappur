import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:math';

enum SocialPlatform {
  youtube,
  instagram,
  facebook,
  twitter,
  linkedin
}

class CreatorProfile {
  final String name;
  final String handle;
  final String description;
  final String subscribers;
  final SocialPlatform platform;
  final String url;
  final String location;
  final String joinDate;
  final String category;
  final List<String> tags;
  final String email;
  final String avatarUrl;
  final String coverImageUrl;
  final int posts;
  final int likes;
  final int shares;

  CreatorProfile({
    required this.name,
    required this.handle,
    required this.description,
    required this.subscribers,
    required this.platform,
    required this.url,
    this.location = '',
    this.joinDate = '',
    this.category = '',
    this.tags = const [],
    this.email = '',
    this.avatarUrl = '',
    this.coverImageUrl = '',
    this.posts = 0,
    this.likes = 0,
    this.shares = 0,
  });
}

class AnimatedSocialButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const AnimatedSocialButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<AnimatedSocialButton> createState() => _AnimatedSocialButtonState();
}

class _AnimatedSocialButtonState extends State<AnimatedSocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;

  const AnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
  });

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _controller.forward().then((_) => _controller.reverse());
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            widget.isLiked ? Icons.favorite : Icons.favorite_border,
            color: widget.isLiked ? Colors.red : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class TalentCorner extends StatefulWidget {
  const TalentCorner({super.key});

  @override
  State<TalentCorner> createState() => _TalentCornerState();
}

class _TalentCornerState extends State<TalentCorner> {
  final Random _random = Random();
  late Timer _timer;
  int _currentImageIndex = 0;
  int _currentProfileIndex = 0;
  int _currentVideoIndex = 0;

  // List of profile images
  final List<String> _profileImages = [
    'https://picsum.photos/200?random=1',
    'https://picsum.photos/200?random=2',
    'https://picsum.photos/200?random=3',
    'https://picsum.photos/200?random=4',
    'https://picsum.photos/200?random=5',
  ];

  // List of post images
  final List<String> _postImages = [
    'https://picsum.photos/300?random=6',
    'https://picsum.photos/300?random=7',
    'https://picsum.photos/300?random=8',
    'https://picsum.photos/300?random=9',
    'https://picsum.photos/300?random=10',
    'https://picsum.photos/300?random=11',
    'https://picsum.photos/300?random=12',
    'https://picsum.photos/300?random=13',
    'https://picsum.photos/300?random=14',
    'https://picsum.photos/300?random=15',
  ];

  // List of video thumbnails
  final List<String> _videoThumbnails = [
    'https://picsum.photos/400?random=16',
    'https://picsum.photos/400?random=17',
    'https://picsum.photos/400?random=18',
    'https://picsum.photos/400?random=19',
    'https://picsum.photos/400?random=20',
  ];

  @override
  void initState() {
    super.initState();
    // Update images every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentImageIndex = _random.nextInt(_postImages.length);
        _currentProfileIndex = _random.nextInt(_profileImages.length);
        _currentVideoIndex = _random.nextInt(_videoThumbnails.length);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _currentProfileImage => _profileImages[_currentProfileIndex];
  String get _currentVideoThumbnail => _videoThumbnails[_currentVideoIndex];

  List<String> get _currentPosts {
    final posts = <String>[];
    for (int i = 0; i < 6; i++) {
      posts.add(_postImages[(_currentImageIndex + i) % _postImages.length]);
    }
    return posts;
  }

  Widget _buildInstagramProfile(BuildContext context, {
    required String username,
    required String fullName,
    required String profileImage,
    required int posts,
    required int followers,
    required int following,
    required String bio,
    required List<String> recentPosts,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade400,
                        Colors.pink.shade400,
                        Colors.orange.shade400,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: CachedNetworkImageProvider(profileImage),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        fullName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInstagramStat('Posts', posts),
                _buildInstagramStat('Followers', followers),
                _buildInstagramStat('Following', following),
              ],
            ),
          ),

          // Bio
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              bio,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Follow'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recent Posts Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            children: recentPosts.map((post) {
              return CachedNetworkImage(
                imageUrl: post,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeProfile(BuildContext context, {
    required String channelName,
    required String profileImage,
    required int subscribers,
    required int videos,
    required String description,
    required List<YouTubeVideo> recentVideos,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Channel Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: CachedNetworkImageProvider(profileImage),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channelName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$subscribers subscribers • $videos videos',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subscribe Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'SUBSCRIBE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Channel Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Videos List
          ...recentVideos.map((video) => _buildVideoCard(video)),

          // Channel Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildYouTubeStat(Icons.thumb_up_outlined, 'Like'),
                _buildYouTubeStat(Icons.share_outlined, 'Share'),
                _buildYouTubeStat(Icons.download_outlined, 'Download'),
                _buildYouTubeStat(Icons.playlist_add_outlined, 'Save'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramStat(String label, int count) {
    String formattedCount = count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}K' : count.toString();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedCount,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(YouTubeVideo video) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: video.thumbnail,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    video.duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${video.views} views • ${video.uploadedAgo}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeStat(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentYouTubeVideos = [
      YouTubeVideo(
        title: 'A Day in Village Life | Pratappur Vlog',
        thumbnail: _videoThumbnails[_currentVideoIndex],
        duration: '12:34',
        views: '1.2K',
        uploadedAgo: '2 days ago',
      ),
      YouTubeVideo(
        title: 'Traditional Festival Celebration | Village Culture',
        thumbnail: _videoThumbnails[(_currentVideoIndex + 1) % _videoThumbnails.length],
        duration: '15:21',
        views: '856',
        uploadedAgo: '5 days ago',
      ),
      YouTubeVideo(
        title: 'Farming Season Special | Rural Life',
        thumbnail: _videoThumbnails[(_currentVideoIndex + 2) % _videoThumbnails.length],
        duration: '18:45',
        views: '2.1K',
        uploadedAgo: '1 week ago',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Talent Corner'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Instagram Profiles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInstagramProfile(
            context,
            username: '@pratappur_dancer',
            fullName: 'Rahul Kumar',
            profileImage: _currentProfileImage,
            posts: 42,
            followers: 1234,
            following: 567,
            bio: '🎭 Classical Dancer\n🏆 State Level Champion\n🎓 Teaching Dance to Village Kids\n🌟 Bringing Art to Pratappur',
            recentPosts: _currentPosts,
          ),
          const SizedBox(height: 24),
          const Text(
            'YouTube Channels',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildYouTubeProfile(
            context,
            channelName: 'Pratappur Vlogs',
            profileImage: _currentProfileImage,
            subscribers: 5600,
            videos: 89,
            description: '📱 Daily Village Life Vlogs\n🎥 Showcasing Rural Culture\n🌾 Agricultural Tips & Tricks\n🤝 Community Stories',
            recentVideos: recentYouTubeVideos,
          ),
        ],
      ),
    );
  }
}

class YouTubeVideo {
  final String title;
  final String thumbnail;
  final String duration;
  final String views;
  final String uploadedAgo;

  const YouTubeVideo({
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.views,
    required this.uploadedAgo,
  });
}

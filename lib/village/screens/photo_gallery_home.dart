import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoGalleryHome extends StatefulWidget {
  const PhotoGalleryHome({super.key});

  @override
  State<PhotoGalleryHome> createState() => _PhotoGalleryHomeState();
}

class _PhotoGalleryHomeState extends State<PhotoGalleryHome> {
  bool isCategoryView = true;
  bool _selectionMode = false;
  final Set<String> _selectedPhotos = {};

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Schools',
      'icon': Icons.school,
      'images': [
        'assets/images/middle_school/middle_school.png',
        'assets/images/middle_school/middleschool.png',
        'assets/images/middle_school/middleschool0.png',
        'assets/images/middle_school/middleschool1.png',
        'assets/images/middle_school/middleschool2.png',
        'assets/images/middle_school/middleschool3.png',
        'assets/images/middle_school/middleschool4.png',
        'assets/images/middle_school/middleschool5.png',
        'assets/images/middle_school/middleschool6.png',
        'assets/images/middle_school/middleschool7.png',
        'assets/images/middle_school/middleschool8.png',
        'assets/images/middle_school/middleschool9.png',
        'assets/images/middle_school/middleschool10.png',
        'assets/images/middle_school/middleschool11.png',
        'assets/images/middle_school/middleschool12.png',
        'assets/images/middle_school/middleschool13.png',
        'assets/images/middle_school/middleschool14.png',
      ],
    },
    {
      'title': 'Temples',
      'icon': Icons.temple_hindu,
      'images': [
        'assets/images/temples/temple1.png',
        'assets/images/temples/temple2.png',
        'assets/images/temples/temple3.png',
      ],
    },
    {
      'title': 'Streets',
      'icon': Icons.streetview,
      'images': [
        'assets/images/streets/street1.png',
        'assets/images/streets/street2.png',
        'assets/images/streets/street3.png',
      ],
    },
    {
      'title': 'Functions',
      'icon': Icons.celebration,
      'images': [
        'assets/images/functions/function1.png',
        'assets/images/functions/function2.png',
        'assets/images/functions/function3.png',
      ],
    },
    {
      'title': 'Festivals',
      'icon': Icons.festival,
      'images': [
        'assets/images/festivals/festival1.png',
        'assets/images/festivals/festival2.png',
        'assets/images/festivals/festival3.png',
      ],
    },
    {
      'title': 'Others',
      'icon': Icons.photo_library,
      'images': [
        'assets/images/others/village1.png',
        'assets/images/others/village2.png',
        'assets/images/others/village3.png',
        'assets/images/others/village4.png',
        'assets/images/others/village5.png',
      ],
    },
  ];

  List<String> get allImages {
    List<String> images = [];
    for (var category in categories) {
      images.addAll(category['images'] as List<String>);
    }
    return images;
  }

  Future<void> _downloadImage(String assetPath) async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      
      // Create a downloads folder if it doesn't exist
      final downloadsDir = Directory('${directory.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create();
      }

      // Extract filename from asset path
      final filename = assetPath.split('/').last;
      final targetPath = '${downloadsDir.path}/$filename';

      // Copy the asset file to downloads directory
      final ByteData data = await DefaultAssetBundle.of(context).load(assetPath);
      final bytes = data.buffer.asUint8List();
      await File(targetPath).writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to downloads: $filename'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedPhotos.clear();
      }
    });
  }

  void _togglePhotoSelection(String imagePath) {
    setState(() {
      if (_selectedPhotos.contains(imagePath)) {
        _selectedPhotos.remove(imagePath);
      } else {
        _selectedPhotos.add(imagePath);
      }
    });
  }

  Future<void> _downloadSelectedPhotos() async {
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select photos to download'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${_selectedPhotos.length} photos for download'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isCategoryView ? 'Photo Gallery' : 'All Photos',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (!isCategoryView) // Only show selection button in grid view
                IconButton(
                  icon: Icon(_selectionMode ? Icons.close : Icons.select_all),
                  onPressed: _toggleSelectionMode,
                ),
              IconButton(
                icon: Icon(
                  isCategoryView ? Icons.grid_on : Icons.category,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    isCategoryView = !isCategoryView;
                    _selectionMode = false;
                    _selectedPhotos.clear();
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          isCategoryView ? _buildCategoryGrid() : _buildAllImagesGrid(),
          if (_selectionMode && _selectedPhotos.isNotEmpty)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _downloadSelectedPhotos,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.download),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      key: const ValueKey('categories'),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _buildGridItem(categories[index]),
    );
  }

  Widget _buildAllImagesGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: categories.length,
      itemBuilder: (context, categoryIndex) {
        final category = categories[categoryIndex];
        final categoryImages = List<String>.from(category['images']);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${categoryImages.length} Photos)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: categoryImages.length,
              itemBuilder: (context, index) {
                final imagePath = categoryImages[index];
                final globalIndex = allImages.indexOf(imagePath);
                final isSelected = _selectedPhotos.contains(imagePath);
                
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_selectionMode) {
                          _togglePhotoSelection(imagePath);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoGallery(
                                images: allImages,
                                initialIndex: globalIndex,
                              ),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!_selectionMode) {
                          _toggleSelectionMode();
                          _togglePhotoSelection(imagePath);
                        }
                      },
                      child: Hero(
                        tag: 'photo$globalIndex',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_selectionMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isSelected ? Icons.check : Icons.circle_outlined,
                            size: 24,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (categoryIndex < categories.length - 1)
              const Divider(height: 32, thickness: 0.5),
          ],
        );
      },
    );
  }

  Widget _buildGridItem(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoGallery(
              images: category['images'],
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category['icon'] as IconData,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            Text(
              category['title'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(category['images'] as List).length} photos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const PhotoGallery({super.key, required this.images, required this.initialIndex});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isDownloading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> _downloadImage(String imageUrl) async {
    if (_isDownloading) return;

    try {
      setState(() {
        _isDownloading = true;
        _hasError = false;
        _errorMessage = '';
      });

      // Validate URL
      final uri = Uri.parse(imageUrl);
      if (!uri.isAbsolute) {
        throw Exception('Invalid image URL');
      }

      // Get download directory
      final directory = await getApplicationDocumentsDirectory();
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }

      // Download image
      final response = await HttpClient().getUrl(uri);
      final HttpClientResponse data = await response.close();
      if (data.statusCode != 200) {
        throw Exception('Failed to download image: ${data.statusCode}');
      }

      List<int> bytes = [];
      await for (var chunk in data) {
        bytes.addAll(chunk);
      }

      if (bytes.isEmpty) {
        throw Exception('Downloaded image is empty');
      }

      // Save image
      final String fileName = imageUrl.split('/').last;
      final String path = '${directory.path}/$fileName';
      final File file = File(path);
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image download feature coming soon!'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(widget.images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                heroAttributes: PhotoViewHeroAttributes(tag: 'image$index'),
              );
            },
            itemCount: widget.images.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _hasError = false;
                _errorMessage = '';
              });
            },
          ),
          // Thumbnail strip at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 70,
              color: Colors.black.withOpacity(0.5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 54,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentIndex == index
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          widget.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

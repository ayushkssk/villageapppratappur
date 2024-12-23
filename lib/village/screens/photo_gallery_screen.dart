import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../services/storage_service.dart';
import '../../models/village_image.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final StorageService _storageService = StorageService();
  final picker = ImagePicker();
  bool _isLoading = false;
  String _loadingText = '';
  List<VillageImage> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      setState(() {
        _isLoading = true;
        _loadingText = 'Loading images...';
      });

      final urls = await _storageService.getImagesFromFolder('gallery');
      setState(() {
        _images = urls.map((url) => VillageImage(
          id: url.split('/').last,
          url: url,
          category: 'gallery',
          uploadedAt: DateTime.now(),
        )).toList();
      });
    } catch (e) {
      debugPrint('Error loading images: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isLoading = true;
        _loadingText = 'Compressing image...';
      });

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedFile == null) {
        throw Exception('Failed to compress image');
      }

      setState(() {
        _loadingText = 'Uploading image...';
      });

      final fileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref('gallery_images/$fileName');

      final uploadTask = ref.putFile(
        File(compressedFile.path),
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        setState(() {
          _loadingText = 'Uploading: ${progress.toStringAsFixed(0)}%';
        });
      });

      await uploadTask;
      final url = await ref.getDownloadURL();

      setState(() {
        _images.insert(0, VillageImage(
          id: url.split('/').last,
          url: url,
          category: 'gallery',
          uploadedAt: DateTime.now(),
        ));
      });

      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      }
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (shouldDelete != true) return;

      await ref.delete();

      setState(() {
        _images.removeWhere((image) => image.url == imageUrl);
      });

      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      }
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      }
    }
  }

  void _viewImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int i) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(_images[i].url),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          itemCount: _images.length,
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(),
          ),
          pageController: PageController(initialPage: index),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_loadingText),
                ],
              ),
            )
          : _images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No photos yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickAndUploadImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Photos'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _viewImage(index),
                      onLongPress: () => _deleteImage(_images[index].url),
                      child: Hero(
                        tag: _images[index].url,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(_images[index].url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: !_isLoading && _images.isNotEmpty
          ? FloatingActionButton(
              onPressed: _pickAndUploadImage,
              child: const Icon(Icons.add_photo_alternate),
            )
          : null,
    );
  }
}

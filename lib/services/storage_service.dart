import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(String path, Uint8List data) async {
    try {
      final ref = _storage.ref(path);
      await ref.putData(data);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<List<String>> getImagesFromFolder(String folderPath) async {
    try {
      // First check if folder exists
      final ref = _storage.ref(folderPath);
      try {
        await ref.getMetadata();
      } catch (e) {
        // If folder doesn't exist, create it by uploading a dummy file
        await ref.child('.placeholder').putString('');
        return [];
      }

      final ListResult result = await ref.listAll();
      if (result.items.isEmpty) return [];

      final urls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()),
      );
      return urls;
    } catch (e) {
      debugPrint('Error getting images: $e');
      return [];
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }
} 
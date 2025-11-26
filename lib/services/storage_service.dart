import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // Upload task image with compression
  Future<String> uploadTaskImage(File imageFile, String workspaceId) async {
    try {
      // Compress image first
      final compressedFile = await _compressImage(imageFile);
      
      // Generate unique filename
      final fileName = '${const Uuid().v4()}.jpg';
      final path = 'workspaces/$workspaceId/tasks/$fileName';
      
      // Upload to Firebase Storage
      final ref = _storage.ref().child(path);
      await ref.putFile(compressedFile);
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String workspaceId,
  ) async {
    final List<String> urls = [];
    
    for (final file in imageFiles) {
      final url = await uploadTaskImage(file, workspaceId);
      urls.add(url);
    }
    
    return urls;
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Compress image
  Future<File> _compressImage(File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${const Uuid().v4()}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 60,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : imageFile;
  }

  // Check if image size is valid
  bool isValidImageSize(File imageFile) {
    final size = imageFile.lengthSync();
    return size <= maxImageSizeBytes;
  }
}

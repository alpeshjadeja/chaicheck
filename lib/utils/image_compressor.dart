import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageCompressor {
  static const int defaultQuality = 60;
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  // Compress a single image
  static Future<File?> compressImage(
    File imageFile, {
    int quality = defaultQuality,
    int minWidth = maxWidth,
    int minHeight = maxHeight,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${const Uuid().v4()}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  // Compress multiple images
  static Future<List<File>> compressMultipleImages(
    List<File> imageFiles, {
    int quality = defaultQuality,
  }) async {
    final List<File> compressedFiles = [];

    for (final file in imageFiles) {
      final compressed = await compressImage(file, quality: quality);
      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }

    return compressedFiles;
  }

  // Get file size in bytes
  static int getFileSize(File file) {
    return file.lengthSync();
  }

  // Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Check if file size is valid
  static bool isValidImageSize(File file) {
    return getFileSize(file) <= maxFileSizeBytes;
  }

  // Get image dimensions
  static Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final info = await FlutterImageCompress.getImageSize(imageFile.path);
      return {
        'width': info.width,
        'height': info.height,
      };
    } catch (e) {
      return null;
    }
  }
}

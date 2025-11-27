import 'dart:async';
import 'dart:io';
import 'package:receive_intent/receive_intent.dart' as receive_intent;

/// Service to handle content shared from other apps
class SharedContentService {
  SharedContentService._();
  static final SharedContentService instance = SharedContentService._();

  StreamSubscription<receive_intent.Intent>? _intentStreamSubscription;

  /// Initialize the service and listen for shared content
  ///
  /// Example usage:
  /// ```dart
  /// SharedContentService.instance.initialize(
  ///   onSharedContent: (intent) {
  ///     print('Received shared content: ${intent.data}');
  ///     // Handle the shared content (text, images, files, etc.)
  ///   },
  /// );
  /// ```
  Future<void> initialize({
    required Function(receive_intent.Intent) onSharedContent,
  }) async {
    // Get the initial intent (app opened from share)
    final initialIntent = await receive_intent.ReceiveIntent.getInitialIntent();
    if (initialIntent != null) {
      onSharedContent(initialIntent);
    }

    // Listen for intents while app is running
    _intentStreamSubscription = receive_intent.ReceiveIntent.receivedIntentStream.listen(
      onSharedContent,
      onError: (error) {
        print('Error receiving shared content: $error');
      },
    );
  }

  /// Stop listening for shared content
  void dispose() {
    _intentStreamSubscription?.cancel();
    _intentStreamSubscription = null;
  }

  /// Helper method to extract shared text from intent
  String? getSharedText(receive_intent.Intent intent) {
    // Check for text in data field
    if (intent.data != null && intent.data!.isNotEmpty) {
      return intent.data;
    }

    // Check for text in extra field
    if (intent.extra != null) {
      final extra = intent.extra as Map<String, dynamic>?;
      if (extra != null && extra.containsKey('android.intent.extra.TEXT')) {
        return extra['android.intent.extra.TEXT'] as String?;
      }
    }

    return null;
  }

  /// Helper method to extract shared file URIs from intent
  List<String> getSharedFileUris(receive_intent.Intent intent) {
    final List<String> uris = [];

    // Check for single file in data field
    if (intent.data != null && intent.data!.isNotEmpty) {
      uris.add(intent.data!);
    }

    // Check for files in extra field
    if (intent.extra != null) {
      final extra = intent.extra as Map<String, dynamic>?;
      if (extra != null) {
        // Single file
        if (extra.containsKey('android.intent.extra.STREAM')) {
          final stream = extra['android.intent.extra.STREAM'];
          if (stream is String) {
            uris.add(stream);
          }
        }

        // Multiple files
        if (extra.containsKey('android.intent.extra.STREAM') &&
            extra['android.intent.extra.STREAM'] is List) {
          final streams = extra['android.intent.extra.STREAM'] as List;
          for (final stream in streams) {
            if (stream is String) {
              uris.add(stream);
            }
          }
        }
      }
    }

    return uris;
  }

  /// Get file path from content URI (Android)
  /// Note: This is a simplified version. You may need to use path_provider
  /// and copy files to app directory for processing.
  Future<String?> getFilePathFromUri(String uri) async {
    if (Platform.isAndroid && uri.startsWith('content://')) {
      // For content:// URIs, you typically need to copy the file to your app's directory
      // This is a placeholder - implement based on your needs
      return uri;
    }

    if (uri.startsWith('file://')) {
      return uri.replaceFirst('file://', '');
    }

    return uri;
  }
}

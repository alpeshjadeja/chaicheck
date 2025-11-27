import 'package:flutter/material.dart';
import 'package:receive_intent/receive_intent.dart' as receive_intent;
import '../services/shared_content_service.dart';

/// Example of how to use SharedContentService in your app
///
/// This example shows how to:
/// 1. Initialize the service in your main app
/// 2. Handle different types of shared content (text, images, files)
/// 3. Display the shared content to the user
///
/// To integrate into your app:
/// 1. Call SharedContentService.instance.initialize() in your main() or initState()
/// 2. Handle the shared content in the onSharedContent callback
/// 3. Don't forget to call SharedContentService.instance.dispose() when done

class SharedContentExample extends StatefulWidget {
  const SharedContentExample({super.key});

  @override
  State<SharedContentExample> createState() => _SharedContentExampleState();
}

class _SharedContentExampleState extends State<SharedContentExample> {
  String _sharedText = '';
  List<String> _sharedFiles = [];

  @override
  void initState() {
    super.initState();
    _initializeSharedContentListener();
  }

  Future<void> _initializeSharedContentListener() async {
    await SharedContentService.instance.initialize(
      onSharedContent: (intent) {
        _handleSharedContent(intent);
      },
    );
  }

  void _handleSharedContent(receive_intent.Intent intent) {
    setState(() {
      // Handle shared text
      final sharedText = SharedContentService.instance.getSharedText(intent);
      if (sharedText != null) {
        _sharedText = sharedText;
        print('Received shared text: $sharedText');
      }

      // Handle shared files (images, documents, etc.)
      final sharedFiles = SharedContentService.instance.getSharedFileUris(intent);
      if (sharedFiles.isNotEmpty) {
        _sharedFiles = sharedFiles;
        print('Received ${sharedFiles.length} shared file(s)');
        for (final file in sharedFiles) {
          print('File URI: $file');
        }
      }

      // Example: Create a new task from shared content
      if (sharedText != null || sharedFiles.isNotEmpty) {
        _createTaskFromSharedContent(sharedText, sharedFiles);
      }
    });
  }

  Future<void> _createTaskFromSharedContent(
    String? text,
    List<String> files,
  ) async {
    // Example implementation: Create a task with the shared content
    // You would integrate this with your TaskProvider or FirestoreService

    print('Creating task from shared content...');

    if (text != null) {
      // Use shared text as task title or description
      print('Task content: $text');
    }

    if (files.isNotEmpty) {
      // Attach shared files to the task
      print('Attaching ${files.length} file(s) to task');
      for (final fileUri in files) {
        final filePath = await SharedContentService.instance.getFilePathFromUri(fileUri);
        print('Processing file: $filePath');
        // Upload to Firebase Storage, attach to task, etc.
      }
    }

    // Show confirmation to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task created from shared content!',
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Navigate to task detail screen
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    SharedContentService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Content Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share content from another app to test this feature',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_sharedText.isNotEmpty) ...[
              const Text(
                'Shared Text:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_sharedText),
              ),
              const SizedBox(height: 20),
            ],
            if (_sharedFiles.isNotEmpty) ...[
              const Text(
                'Shared Files:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(_sharedFiles.map(
                (file) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    file,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )),
            ],
            if (_sharedText.isEmpty && _sharedFiles.isEmpty)
              const Center(
                child: Text(
                  'No shared content yet.\n\nTry sharing text or files from another app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

# Shared Content Integration Guide

This app now supports receiving shared content from other apps using the `receive_intent` package (JVM 17 compatible).

## Features

Your app can now receive:
- ✅ Shared text from any app
- ✅ Single or multiple images
- ✅ Any file type (documents, PDFs, etc.)
- ✅ URLs and links

## How It Works

When users tap "Share" in another app (Gallery, Browser, Notes, etc.) and select ChaiCheck, your app will:
1. Open automatically (or come to foreground if already running)
2. Receive the shared content via `SharedContentService`
3. Allow you to process the content (create tasks, save files, etc.)

## Quick Integration

### Step 1: Initialize in Your App

Add this to your main app widget or home screen `initState()`:

```dart
import 'package:chaicheck/services/shared_content_service.dart';

@override
void initState() {
  super.initState();
  _initializeSharedContent();
}

Future<void> _initializeSharedContent() async {
  await SharedContentService.instance.initialize(
    onSharedContent: (intent) {
      // Handle the shared content
      _handleSharedContent(intent);
    },
  );
}

void _handleSharedContent(Intent intent) {
  // Get shared text
  final text = SharedContentService.instance.getSharedText(intent);
  if (text != null) {
    // Create a task with the text
    print('Received text: $text');
  }

  // Get shared files
  final files = SharedContentService.instance.getSharedFileUris(intent);
  if (files.isNotEmpty) {
    // Process the shared files
    print('Received ${files.length} file(s)');
  }
}
```

### Step 2: Don't Forget Cleanup

```dart
@override
void dispose() {
  SharedContentService.instance.dispose();
  super.dispose();
}
```

## Example Use Cases

### 1. Create Task from Shared Text

```dart
void _handleSharedContent(Intent intent) {
  final text = SharedContentService.instance.getSharedText(intent);
  if (text != null) {
    // Navigate to create task screen with pre-filled content
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(
          initialDescription: text,
        ),
      ),
    );
  }
}
```

### 2. Attach Shared Images to Task

```dart
void _handleSharedContent(Intent intent) async {
  final files = SharedContentService.instance.getSharedFileUris(intent);

  for (final fileUri in files) {
    final filePath = await SharedContentService.instance.getFilePathFromUri(fileUri);
    // Upload to Firebase Storage
    // Attach to task
  }
}
```

### 3. Save Shared URL as Task

```dart
void _handleSharedContent(Intent intent) {
  final url = SharedContentService.instance.getSharedText(intent);
  if (url != null && url.startsWith('http')) {
    // Create a task with the URL as a link
    createTaskFromUrl(url);
  }
}
```

## Full Example

See `lib/examples/shared_content_example.dart` for a complete working example with UI.

## Platform Configuration

### Android ✅
Intent filters have been added to `AndroidManifest.xml` to handle:
- Text content
- Images (single and multiple)
- All file types (single and multiple)

### iOS ✅
Document types have been added to `Info.plist` to handle:
- Images
- Text files
- Documents
- Any content

## Testing

### On Android:
1. Open Gallery app
2. Select an image
3. Tap Share button
4. Select "ChaiCheck" from the list
5. Your app should open with the image

### On iOS:
1. Open Safari or Photos
2. Tap the Share button
3. Find and tap "ChaiCheck"
4. Your app should open with the content

## API Reference

### SharedContentService

#### Methods

- `initialize({required Function(Intent) onSharedContent})` - Start listening for shared content
- `dispose()` - Stop listening (call in dispose())
- `getSharedText(Intent)` - Extract text from intent
- `getSharedFileUris(Intent)` - Extract file URIs from intent
- `getFilePathFromUri(String)` - Convert URI to file path

## Notes

- The service is a singleton: `SharedContentService.instance`
- Always call `dispose()` when you're done listening
- File URIs may need to be copied to your app's directory for processing
- On Android, content:// URIs require special handling (use `path_provider`)

## Migration from receive_sharing_intent

If you were using `receive_sharing_intent` before, the API is similar but with better JVM 17 compatibility:

| Old (receive_sharing_intent) | New (receive_intent) |
|------------------------------|----------------------|
| ReceiveSharingIntent | ReceiveIntent |
| getInitialMedia() | getInitialIntent() |
| getMediaStream() | receivedIntentStream |

## Troubleshooting

**App doesn't appear in share menu:**
- Make sure you ran `flutter pub get`
- Rebuild the app completely: `flutter clean && flutter run`
- Check that intent filters are in AndroidManifest.xml
- Check that document types are in Info.plist

**Received content is null:**
- Check that the intent has data using `print(intent.data)`
- Try logging the entire intent: `print(intent.toString())`
- Some apps may send content in different formats

## Support

- Package: [receive_intent on pub.dev](https://pub.dev/packages/receive_intent)
- Issues: Report in the app's GitHub repository

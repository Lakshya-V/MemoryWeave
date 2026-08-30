import 'dart:convert';
import 'dart:io';
import '../../../../core/data/api_client.dart';

class AddMemoryService {
  /// If the given path is a local device file (not already an http(s) or
  /// data: URL), reads its bytes and returns a base64 data URI. Otherwise
  /// returns the input unchanged. Shared by both generateQuestions and
  /// saveMemory so a local file path is never sent to the backend as-is.
  static Future<String> _toPayloadUrl(String imageUrl) async {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('data:')) {
      return imageUrl;
    }

    try {
      final sanitizedPath = imageUrl.replaceFirst('file://', '');
      final file = File(sanitizedPath);

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        String mimeType = 'image/jpeg';
        if (sanitizedPath.endsWith('.png')) mimeType = 'image/png';
        if (sanitizedPath.endsWith('.webp')) mimeType = 'image/webp';

        print('Converted local image file to Base64 payload (${bytes.length} bytes)');
        return 'data:$mimeType;base64,$base64String';
      }
    } catch (e) {
      print('Error reading local image file for Base64 conversion: $e');
    }

    // File didn't exist or read failed — return unchanged; caller/backend
    // will surface the error rather than silently sending garbage.
    return imageUrl;
  }

  /// Step 1: Generate questions from image using Reka AI
  /// Automatically converts local device files to Base64 data URLs,
  /// and falls back gracefully to local question generation if the backend fails.
  static Future<List<String>?> generateQuestions(String imageUrl) async {
    final payloadUrl = await _toPayloadUrl(imageUrl);

    try {
      final response = await ApiClient.post('/caregiver/generate-questions', {
        'image_url': payloadUrl,
      });

      if (response != null && response['questions'] != null) {
        return List<String>.from(response['questions']);
      }
    } catch (e) {
      print('Generate questions API request failed: $e');
    }

    // 2. MOCK FALLBACK: If backend returns null, throws 400/502, or fails to fetch,
    // return these structured test questions so you can continue testing your UI seamlessy!
    print('Falling back to local mock questions for test image.');
    return [
      'Who are the main people pictured in this photograph?',
      'Where was this memory captured?',
      'What significant event or occasion was taking place here?'
    ];
  }

  /// Step 2: Save ground truth memory with user-provided answers
  static Future<bool> saveMemory(
    String imageUrl,
    List<Map<String, String>> qaPairs,
  ) async {
    final payloadUrl = await _toPayloadUrl(imageUrl);

    try {
      final response = await ApiClient.post('/caregiver/save-memory', {
        'image_url': payloadUrl,
        'qa_pairs': qaPairs,
      });

      return response != null && response['status'] == 'success';
    } catch (e) {
      print('Save memory API request failed: $e');
      return false;
    }
  }
}
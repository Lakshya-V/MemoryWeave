import '../../../../../core/data/api_client.dart';

class QuizService {
  static Future<Map<String, dynamic>?> fetchNextQuiz() async {
    return await ApiClient.get('/activity/next');
  }

  static Future<Map<String, dynamic>?> submitEvaluation({
    required String memoryId,
    required String transcribedText,
    required int latencyMs,
  }) async {
    return await ApiClient.post('/activity/evaluate', {
      'memory_id': memoryId,
      'transcribed_text': transcribedText,
      'latency_ms': latencyMs,
    });
  }
}
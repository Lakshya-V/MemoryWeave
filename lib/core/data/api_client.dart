import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://1mm1p9jm-8000.inc1.devtunnels.ms';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Tunnel-Skip-Anti-Phishing-Page': 'true',
      };

  static Future<Map<String, dynamic>?> get(String path) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
          )
          // Mandatory 60s timeout for Reka AI backend processing
          .timeout(const Duration(seconds: 60));

      print('GET Status ($path): ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('GET Exception ($path): $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> post(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          // Mandatory 60s timeout for Reka AI backend processing
          .timeout(const Duration(seconds: 60));

      print('POST Status ($path): ${response.statusCode}');
      print('POST Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('POST Exception ($path): $e');
      return null;
    }
  }
}
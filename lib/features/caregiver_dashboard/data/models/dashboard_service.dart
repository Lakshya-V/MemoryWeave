import '../../../../core/data/api_client.dart';

class DashboardService {
  /// Fetches analytics for a given user: behavioral_state, clinical_insight,
  /// total_sessions, and whatever else the backend includes.
  static Future<Map<String, dynamic>?> fetchDashboard(String userId) async {
    return await ApiClient.get('/caregiver/dashboard?user_id=$userId');
  }

  /// Fetches every saved memory for the Active Memory Library list.
  /// Requires the new GET /caregiver/memories endpoint on the backend
  /// (see backend_memories_endpoint.py) — returns null if it 404s so the
  /// UI can show an empty state instead of crashing on an old backend.
  static Future<List<Map<String, dynamic>>?> fetchMemories() async {
    final response = await ApiClient.get('/caregiver/memories');
    if (response == null || response['memories'] == null) return null;
    return List<Map<String, dynamic>>.from(response['memories']);
  }
}
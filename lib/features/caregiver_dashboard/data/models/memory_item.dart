class MemoryItem {
  final String id;
  final String title;
  final String dateAdded;
  final String? imageUrl;
  final String contextDescription;
  final int timesPrompted;
  final int avgRecallAccuracy;

  const MemoryItem({
    required this.id,
    required this.title,
    required this.dateAdded,
    this.imageUrl,
    required this.contextDescription,
    this.timesPrompted = 6,
    this.avgRecallAccuracy = 92,
  });

  /// Builds a MemoryItem from the JSON shape returned by
  /// GET /caregiver/memories (see backend_memories_endpoint.py).
  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    // Backend doesn't store a caregiver-given title, so derive a short
    // one from the ground_truth summary (first Q:A segment before " | ").
    final groundTruth = json['ground_truth']?.toString() ?? '';
    final firstSegment = groundTruth.split('|').first.trim();
    final title = firstSegment.isNotEmpty ? firstSegment : 'Untitled memory';

    String dateAdded = 'Unknown date';
    final createdAt = json['created_at']?.toString();
    if (createdAt != null && createdAt.isNotEmpty) {
      final parsed = DateTime.tryParse(createdAt);
      if (parsed != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        dateAdded = '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
      }
    }

    return MemoryItem(
      id: json['memory_id']?.toString() ?? '',
      title: title,
      dateAdded: dateAdded,
      imageUrl: json['image_url']?.toString(),
      contextDescription: groundTruth,
      timesPrompted: (json['times_prompted'] as num?)?.toInt() ?? 0,
      avgRecallAccuracy: (json['avg_recall_accuracy'] as num?)?.toInt() ?? 0,
    );
  }
}
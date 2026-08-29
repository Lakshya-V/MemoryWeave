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
}

class Point {
  final int id;
  final String userId;
  final String latitude;
  final String longitude;
  final DateTime timestamp;
  final String description;
  final String category;
  final String event;
  int votes;

  Point({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.description,
    required this.category,
    required this.event,
    required this.votes,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      id: json['id'] ?? 0, // Default value or handle null appropriately
      userId: json['userId'],
      latitude:
          json['latitude'] ?? '', // Default value or handle null appropriately
      longitude:
          json['longitude'] ?? '', // Default value or handle null appropriately
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'] ??
          '', // Default value or handle null appropriately
      category:
          json['category'] ?? '', // Default value or handle null appropriately
      event: json['event'],
      votes: json['votes'],
    );
  }
}

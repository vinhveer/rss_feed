class FeedItem {
  final String title;
  final String source;
  final String timeAgo;
  final String imageUrl;
  final String category;

  FeedItem({
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.imageUrl,
    required this.category,
  });

  // Factory to create from JSON (for future API integration)
  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      title: json['title'] ?? '',
      source: json['source'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'source': source,
      'timeAgo': timeAgo,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
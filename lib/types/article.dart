class ArticleData {
  final String title;
  final String text;
  final List<dynamic> images;
  final String pubDate;
  final String author;

  ArticleData({
    required this.title,
    required this.text,
    required this.images,
    required this.pubDate,
    required this.author,
  });

  factory ArticleData.fromJson(Map<String, dynamic> json) {
    return ArticleData(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      images: (json['images'] ?? []) as List<dynamic>,
      pubDate: json['pubDate'] ?? '',
      author: json['author'] ?? '',
    );
  }
}

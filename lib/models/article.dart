class ArticleData {
  final String title;
  final String text;
  final List<String> images;
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
      title: json['title'] ?? 'Không rõ',
      text: json['text'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      pubDate: json['pubDate'] ?? 'Không rõ',
      author: json['author'] ?? 'Không rõ',
    );
  }
}
class RecommendArticle {
  final int articleId;
  final String title;
  final String link;
  final String imageUrl;
  final String description;
  final DateTime pubDate;
  final int rssId;

  RecommendArticle({
    required this.articleId,
    required this.title,
    required this.link,
    required this.imageUrl,
    required this.description,
    required this.pubDate,
    required this.rssId,
  });

  factory RecommendArticle.fromJson(Map<String, dynamic> json) {
    return RecommendArticle(
      articleId: json['article_id'],
      title: json['title'],
      link: json['link'],
      imageUrl: json['image_url'],
      description: json['description'],
      pubDate: DateTime.parse(json['pub_date']),
      rssId: json['rss_id'],
    );
  }
} 
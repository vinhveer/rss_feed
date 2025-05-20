class FeedItem {
  final String title;
  final String source;
  final String timeAgo;
  final String imageUrl;
  final String category;
  final String link;
  final List<String> keywords;
  final bool isVn;

  FeedItem({
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.imageUrl,
    required this.category,
    required this.link,
    this.keywords = const [],
    required this.isVn,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final rss = json['rss'] ?? {};
    final topic = rss['topic'] ?? {};
    final newspaper = rss['newspaper'] ?? {};

    final articleKeywords = (json['article_keyword'] ?? []) as List;
    final keywordList = articleKeywords.map<String>((kw) {
      return kw['keyword']?['keyword_name'] ?? '';
    }).where((kw) => kw.isNotEmpty).toList();

    return FeedItem(
      title: json['title'] ?? '',
      source: json['description'] ?? '',
      timeAgo: json['pub_date'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: topic['topic_name'] ?? '',
      link: json['link'] ?? '',
      keywords: keywordList,
      isVn: newspaper['is_vn'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'source': source,
      'timeAgo': timeAgo,
      'imageUrl': imageUrl,
      'category': category,
      'link': link,
      'keywords': keywords,
      'isVn': isVn,
    };
  }
}

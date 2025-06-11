class RecommendKeyword {
  final int keywordId;
  final String keywordName;
  final int articleCount;

  RecommendKeyword({
    required this.keywordId,
    required this.keywordName,
    required this.articleCount,
  });

  factory RecommendKeyword.fromJson(Map<String, dynamic> json) {
    return RecommendKeyword(
      keywordId: json['keyword_id'],
      keywordName: json['keyword_name'],
      articleCount: json['article_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword_id': keywordId,
      'keyword_name': keywordName,
      'article_count': articleCount,
    };
  }
} 
class FavouriteItem {
  final int id;
  final String userId;
  final String title;
  final String? description;
  final String? imageUrl;
  final String link;
  final DateTime pubDate;

  FavouriteItem({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.link,
    required this.pubDate,
  });

  factory FavouriteItem.fromMap(Map<String, dynamic> map) {    
    final article = map['article'] as Map<String, dynamic>?;
    if (article == null) {
      throw Exception('Article data is null in favourite item: $map');
    }

    return FavouriteItem(
      id: map['article_id'] as int,
      userId: map['user_id'] as String,
      title: article['title'] as String,
      description: article['description'] as String?,
      imageUrl: article['image_url'] as String?,
      link: article['link'] as String,
      pubDate: DateTime.parse(article['pub_date'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  factory FavouriteItem.fromMapDirect(Map<String, dynamic> map, String userId) {    
    return FavouriteItem(
      id: map['article_id'] as int,
      userId: userId,
      title: map['title'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      link: map['link'] as String,
      pubDate: DateTime.parse(map['pub_date'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'article_id': id,
      'user_id': userId,
    };
  }
}
import 'package:rss_feed/row_row_row/tables/article.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticleRepository {
  ArticleRepository();

  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'article';

  /// Fetches all articles from the database
  Future<List<ArticleRow>> getAllArticles() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*')  // Chỉ rõ tất cả các cột
          .timeout(const Duration(seconds: 10));

      // Thử parse từng record và ghi log nếu có lỗi
      final articles = <ArticleRow>[];
      for (var item in response as List) {
          articles.add(ArticleRow.fromJson(item));
      }

      return articles;
    } catch (e) {
      throw SupabaseException(message: e.toString());
    }
  }

  /// Fetches articles by RSS ID
  Future<List<ArticleRow>> getArticlesByRssId(int rssId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq(ArticleRow.field.rssId, rssId);
    return (response as List)
        .map((json) => ArticleRow.fromJson(json))
        .toList();
  }

  /// Fetches a single article by ID
  Future<ArticleRow?> getArticleById(int articleId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq(ArticleRow.field.articleId, articleId)
        .maybeSingle();
    if (response == null) return null;
    return ArticleRow.fromJson(response);
  }

  /// Searches articles by title
  Future<List<ArticleRow>> searchArticlesByTitle(String query) async {
    final response = await _client
        .from(_tableName)
        .select()
        .ilike(ArticleRow.field.title, '%$query%');
    return (response as List)
        .map((json) => ArticleRow.fromJson(json))
        .toList();
  }

  /// Fetches articles published after a specific date
  Future<List<ArticleRow>> getArticlesAfterDate(DateTime date) async {
    final response = await _client
        .from(_tableName)
        .select()
        .gt(ArticleRow.field.pubDate, date.toIso8601String());
    return (response as List)
        .map((json) => ArticleRow.fromJson(json))
        .toList();
  }
}

/// Exception for handling Supabase errors
class SupabaseException implements Exception {
  final String message;
  SupabaseException({required this.message});

  @override
  String toString() => 'SupabaseException: $message';
}
import 'package:rss_feed/row_row_row_generated/tables/article.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ArticleRepository {
  ArticleRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.instance.client;

  final SupabaseClient _client;
  final String _tableName = 'articles';

  /// Fetches all articles from the database
  Future<List<ArticleRow>> getAllArticles() async {
    final response = await _client.from(_tableName).select();
    return (response as List)
        .map((json) => ArticleRow.fromJson(json))
        .toList();
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

  /// Creates a new article
  Future<ArticleRow> createArticle(ArticleRow article) async {
    final response = await _client
        .from(_tableName)
        .insert(article.toJson())
        .select()
        .single();
    return ArticleRow.fromJson(response);
  }

  /// Updates an existing article
  Future<ArticleRow> updateArticle(ArticleRow article) async {
    final response = await _client
        .from(_tableName)
        .update(article.toJson())
        .eq(ArticleRow.field.articleId, article.articleId)
        .select()
        .single();
    return ArticleRow.fromJson(response);
  }

  /// Deletes an article by ID
  Future<void> deleteArticle(int articleId) async {
    await _client
        .from(_tableName)
        .delete()
        .eq(ArticleRow.field.articleId, articleId);
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
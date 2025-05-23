import 'package:supabase_flutter/supabase_flutter.dart';
import '../row_row_row/tables/article.row.dart';

class ArticleRepository {
  final SupabaseClient _client = Supabase.instance.client;
  static const int _pageSize = 10;

  Future<List<ArticleRow>> getArticlesByTopic({
    required String topicId,
    int page = 0,
  }) async {
    try {
      final response = await _client
          .from(ArticleRow.table)
          .select()
          .eq('topic_id', topicId)
          .order(ArticleRow.field.pubDate, ascending: false)
          .range(page * _pageSize, (page + 1) * _pageSize - 1);

      print('Response: $response');

      return response.map((json) => ArticleRow.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching articles by topic: $e');
      rethrow;
    }
  }

  Future<List<ArticleRow>> getArticlesByNewspaper({
    required String newspaperId,
    String? category,
    int page = 0,
  }) async {
    try {
      final response = await _client
          .from(ArticleRow.table)
          .select()
          .eq('newspaper_id', newspaperId)
          .order(ArticleRow.field.pubDate, ascending: false)
          .range(page * _pageSize, (page + 1) * _pageSize - 1);

      return response.map((json) => ArticleRow.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching articles by newspaper: $e');
      rethrow;
    }
  }

  Future<List<String>> getCategoriesByNewspaper(String newspaperId) async {
    try {
      // Since there's no category field in the schema, we'll return a default list
      return ['Mới nhất'];
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }
} 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../row_row_row/tables/article.row.dart';
import '../types/feed_item_local.dart';

class SearchRepository {
  final SupabaseClient _client = Supabase.instance.client;
  static const int pageSize = 10;

  Future<List<FeedItem>> searchArticles(String query, {int page = 0}) async {
    try {
      final response = await _client
          .from(ArticleRow.table)
          .select('*, rss:rss_id(topic:topic_id(topic_name), newspaper:newspaper_id(is_vn))')
          .ilike(ArticleRow.field.title, '%$query%')
          .order(ArticleRow.field.pubDate, ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return response.map((json) {
        return FeedItem.fromJson(json);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasMoreResults(String query, int currentPage) async {
    try {
      final response = await _client
          .from(ArticleRow.table)
          .select('article_id')
          .ilike(ArticleRow.field.title, '%$query%');
      
      return response.length > (currentPage + 1) * pageSize;
    } catch (e) {
      return false;
    }
  }
} 
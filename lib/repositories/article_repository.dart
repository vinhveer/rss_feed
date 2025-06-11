import 'package:supabase_flutter/supabase_flutter.dart';
import '../types/feed_item_local.dart';
import '../row_row_row/tables/topic.row.dart';

class ArticleRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const int defaultLimit = 20;

  /// Lấy bài viết theo topic_id
  Future<List<FeedItem>> getArticlesByTopic({
    required int topicId,
    int offset = 0,
    int limit = defaultLimit,
    bool sortAscending = false,
  }) async {
    try {
      // Lấy danh sách rss_id thuộc topic
      final rssResponse = await _client
          .from('rss')
          .select('id')
          .eq('topic_id', topicId);

      final rssIds = (rssResponse as List).map<int>((e) => (e['id'] as num).toInt()).toList();
      if (rssIds.isEmpty) return [];

      final response = await _client
          .from('article')
          .select('''
            article_id,
            title,
            link,
            image_url,
            pub_date,
            description,
            rss:rss_id (
              rss_link,
              topic:topic_id (
                topic_name
              ),
              newspaper(is_vn)
            ),
            article_keyword (
              keyword:keyword_id (
                keyword_name
              )
            )
          ''')
          .inFilter('rss_id', rssIds)
          .order('pub_date', ascending: sortAscending)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map<FeedItem>((json) => FeedItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getArticlesByTopic: $e');
      rethrow;
    }
  }

  /// Lấy bài viết theo newspaper_id (có thể kèm topic_id)
  Future<List<FeedItem>> getArticlesByNewspaper({
    required int newspaperId,
    int? topicId,
    int offset = 0,
    int limit = defaultLimit,
    bool sortAscending = false,
  }) async {
    try {
      var rssQuery = _client
          .from('rss')
          .select('id')
          .eq('newspaper_id', newspaperId);

      if (topicId != null) {
        rssQuery = rssQuery.eq('topic_id', topicId);
      }

      final rssResponse = await rssQuery;
      final rssIds = (rssResponse as List).map<int>((e) => (e['id'] as num).toInt()).toList();
      if (rssIds.isEmpty) return [];

      final response = await _client
          .from('article')
          .select('''
            article_id,
            title,
            link,
            image_url,
            pub_date,
            description,
            rss:rss_id (
              rss_link,
              topic:topic_id (
                topic_name
              ),
              newspaper(is_vn)
            ),
            article_keyword (
              keyword:keyword_id (
                keyword_name
              )
            )
          ''')
          .inFilter('rss_id', rssIds)
          .order('pub_date', ascending: sortAscending)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map<FeedItem>((json) => FeedItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getArticlesByNewspaper: $e');
      rethrow;
    }
  }

  /// Lấy danh sách topic thuộc newspaper
  Future<List<TopicRow>> getTopicsByNewspaper(int newspaperId) async {
    try {
      final response = await _client
          .from('rss')
          .select('topic:topic_id (topic_id, topic_name, topic_image)')
          .eq('newspaper_id', newspaperId);

      final topicsRaw = (response as List)
          .map<Map<String, dynamic>>((e) => (e['topic'] ?? {}) as Map<String, dynamic>)
          .where((json) => json.isNotEmpty)
          .map<TopicRow>((json) => TopicRow.fromJson(json))
          .toList();

      // Loại bỏ trùng lặp
      final Map<int, TopicRow> unique = {};
      for (final t in topicsRaw) {
        unique[t.topicId] = t;
      }

      return unique.values.toList();
    } catch (e) {
      print('Error getTopicsByNewspaper: $e');
      rethrow;
    }
  }
} 